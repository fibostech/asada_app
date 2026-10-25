import 'dart:convert';
import 'dart:math';
import 'dio/dio.dart' as dio;

import '../models/meter.dart';
import '../models/reading.dart';
import '../models/route.dart';

/// Servicio de gestión de medidores y lecturas offline.
class MeterService {
  final dio.Dio _http;
  final String _serverUrl;
  final String _apiKey;
  final List<Route> _localRoutes = [];
  final List<Reading> _pendingReadings = [];

  const MeterService({
    required dio.Dio http,
    required String serverUrl,
    required String apiKey,
  })  : _http = http,
        _serverUrl = serverUrl,
        _apiKey = apiKey;

  /// Obtiene rutas locales (ya descargadas).
  List<Route> get localRoutes => List.unmodifiable(_localRoutes);

  /// Obtiene lecturas pendientes de sincronizar.
  List<Reading> get pendingReadings =>
      _pendingReadings.where((r) => !r.synced).toList();

  /// Obtiene todas las lecturas.
  List<Reading> get allReadings => List.unmodifiable(_pendingReadings);

  /// Almacena rutas en local.
  void setRoutes(List<Route> routes) {
    _localRoutes.clear();
    _localRoutes.addAll(routes);
  }

  /// Registra una lectura localmente.
  Future<void> saveReading(Reading reading) async {
    _pendingReadings.add(reading);
    // En producción se persiste a Isar DB.
  }

  /// Marca lecturas como sincronizadas.
  Future<void> markAsSynced(List<Reading> readings) async {
    for (final r in readings) {
      final idx = _pendingReadings.indexOf(r);
      if (idx >= 0) {
        _pendingReadings[idx] = Reading(
          id: r.id,
          meterId: r.meterId,
          meterCode: r.meterCode,
          value: r.value,
          photoPath: r.photoPath,
          ocrText: r.ocrText,
          ocrSuccess: r.ocrSuccess,
          status: r.status,
          scenario: r.scenario,
          notes: r.notes,
          timestamp: r.timestamp,
          synced: true,
        );
      }
    }
  }

  /// Busca un medidor por código QR.
  Meter? findMeterByQr(String qrData) {
    for (final route in _localRoutes) {
      for (final meter in route.meters) {
        if (meter.qrCode == qrData) return meter;
      }
    }
    return null;
  }

  /// Busca un medidor por código.
  Meter? findMeterByCode(String code) {
    for (final route in _localRoutes) {
      for (final meter in route.meters) {
        if (meter.code == code) return meter;
      }
    }
    return null;
  }

  /// Obtiene el historial de lecturas de un medidor.
  List<Reading> getReadingHistory(int meterId) {
    return _pendingReadings
        .where((r) => r.meterId == meterId)
        .toList();
  }
}