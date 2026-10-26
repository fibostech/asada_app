import 'dart:async';
import 'dart:math' as math;

import '../models/meter.dart';
import '../models/reading.dart';
import '../services/camera_service.dart';
import '../services/ocr_service.dart';
import '../services/meter_service.dart';

/// Estados del BLoC de lectura.
enum ReadingBlocState {
  initial,
  capturing,
  processingOcr,
  validating,
  completed,
  manualEntry,
  error,
}

/// Resultado de una lectura completada.
class ReadingResult {
  final Reading reading;
  final bool success;
  final String? message;

  const ReadingResult({
    required this.reading,
    required this.success,
    this.message,
  });
}

/// BLoC de proceso de lectura.
class ReadingBloc {
  final CameraService _cameraService;
  final OcrService _ocrService;
  final MeterService _meterService;

  ReadingBlocState _state = ReadingBlocState.initial;
  String? _errorMessage;
  String? _currentPhotoPath;
  String? _ocrText;
  Meter? _currentMeter;
  StreamController<ReadingBlocState>? _stateController;
  late final Stream<ReadingBlocState> stateChanges;

  ReadingBloc({
    required CameraService cameraService,
    required OcrService ocrService,
    required MeterService meterService,
  })  : _cameraService = cameraService,
        _ocrService = ocrService,
        _meterService = meterService {
    _stateController = StreamController<ReadingBlocState>();
    stateChanges = _stateController!.stream;
  }

  ReadingBlocState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get currentPhotoPath => _currentPhotoPath;
  String? get ocrText => _ocrText;
  Meter? get currentMeter => _currentMeter;

  /// Inicia el proceso de lectura para un medidor.
  Future<ReadingResult> startReading(Meter meter) async {
    _currentMeter = meter;
    _currentPhotoPath = null;
    _ocrText = null;

    // 1. Capturar foto
    _state = ReadingBlocState.capturing;
    _emitState();

    final photoPath = await _cameraService.capturePhoto();
    if (photoPath == null) {
      _state = ReadingBlocState.error;
      _errorMessage = 'Captura de foto cancelada';
      _emitState();
      return ReadingResult(
        reading: _createPendingReading(meter),
        success: false,
        message: _errorMessage,
      );
    }

    _currentPhotoPath = photoPath;

    // Validar foto
    final isValid = await _cameraService.validatePhoto(photoPath);
    if (!isValid) {
      _state = ReadingBlocState.error;
      _errorMessage = 'Foto inválida o muy pequeña';
      _emitState();
      return ReadingResult(
        reading: _createPendingReading(meter, photoPath: photoPath),
        success: false,
        message: _errorMessage,
      );
    }

    // 2. Procesar OCR
    _state = ReadingBlocState.processingOcr;
    _emitState();

    final ocrResult = await _ocrService.performOcr(photoPath);
    _ocrText = ocrResult;

    if (ocrResult != null && OcrService.validateReading(ocrResult)) {
      // OCR exitoso
      final cleaned = OcrService.sanitizeReading(ocrResult);
      final readingValue = double.parse(cleaned);

      // Validar que lectura >= última lectura registrada
      final validationError = _validateReadingValue(meter, readingValue);
      if (validationError != null) {
        _state = ReadingBlocState.error;
        _errorMessage = validationError;
        _emitState();
        return ReadingResult(
          reading: _createPendingReading(meter, photoPath: photoPath),
          success: false,
          message: validationError,
        );
      }

      _state = ReadingBlocState.validating;
      _emitState();

      final reading = Reading(
        id: _generateUuid(),
        meterId: meter.id,
        meterCode: meter.code,
        value: readingValue,
        photoPath: photoPath,
        ocrText: ocrResult,
        ocrSuccess: true,
        status: ReadingStatus.completed,
        scenario: _detectScenario(meter),
        timestamp: DateTime.now(),
      );

      await _meterService.saveReading(reading);

      _state = ReadingBlocState.completed;
      _emitState();
      return ReadingResult(reading: reading, success: true);
    }

    // 3. OCR falló — ingreso manual
    _state = ReadingBlocState.manualEntry;
    _emitState();
    return ReadingResult(
      reading: _createPendingReading(meter, photoPath: photoPath),
      success: false,
      message: 'No se pudo leer el medidor automáticamente. '
          'Ingrese el valor manualmente.',
    );
  }

  /// Guarda una lectura con ingreso manual.
  Future<ReadingResult> saveManualReading(
      Meter meter, double value, String? notes) async {
    // Validar que lectura >= última lectura registrada
    final validationError = _validateReadingValue(meter, value);
    if (validationError != null) {
      _state = ReadingBlocState.error;
      _errorMessage = validationError;
      _emitState();
      return ReadingResult(
        reading: _createPendingReading(meter, photoPath: _currentPhotoPath),
        success: false,
        message: validationError,
      );
    }

    final reading = Reading(
      id: _generateUuid(),
      meterId: meter.id,
      meterCode: meter.code,
      value: value,
      photoPath: _currentPhotoPath,
      ocrText: _ocrText,
      ocrSuccess: false,
      status: ReadingStatus.manual,
      scenario: _detectScenario(meter),
      notes: notes,
      timestamp: DateTime.now(),
    );

    await _meterService.saveReading(reading);

    _state = ReadingBlocState.completed;
    _emitState();
    return ReadingResult(reading: reading, success: true);
  }

  /// Valida que el valor de lectura no sea menor a la última registrada.
  /// Retorna null si es válido, o un mensaje de error si no.
  String? _validateReadingValue(Meter meter, double newValue) {
    if (meter.lastReadingValue == null) return null;
    final lastValue = double.tryParse(meter.lastReadingValue!);
    if (lastValue == null) return null;
    if (newValue < lastValue) {
      return 'El valor ingresado ($newValue) es menor que la '
          'última lectura registrada ($lastValue). '
          'Verifique el medidor.';
    }
    return null;
  }

  /// Determina el escenario de facturación según datos del medidor.
  BillingScenario _detectScenario(Meter meter) {
    // Por defecto meteredOwn; en producción se obtiene del servidor.
    return BillingScenario.meteredOwn;
  }

  Reading _createPendingReading(Meter meter, {String? photoPath}) => Reading(
    id: _generateUuid(),
    meterId: meter.id,
    meterCode: meter.code,
    photoPath: photoPath,
    status: ReadingStatus.pending,
    timestamp: DateTime.now(),
  );

  String _generateUuid() {
    final rnd = math.Random();
    return '${rnd.nextInt(99999999).toString().padLeft(8, '0')}'
        '-${rnd.nextInt(99999999).toString().padLeft(8, '0')}'
        '-${rnd.nextInt(99999999).toString().padLeft(8, '0')}';
  }

  void _emitState() {
    _stateController?.add(_state);
  }

  void dispose() {
    _stateController?.close();
  }
}