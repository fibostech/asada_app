import 'dart:convert';

/// Escenario de facturación del medidor.
enum BillingScenario {
  flatFee,
  meteredOwn,
  meteredRegulated,
}

/// Estado de la lectura.
enum ReadingStatus {
  pending,
  completed,
  failed,
  manual,
}

/// Lectura de un medidor.
class Reading {
  final String id; // UUID local
  final int meterId;
  final String meterCode;
  final double? value;
  final String? photoPath;
  final String? ocrText;
  final bool ocrSuccess;
  final ReadingStatus status;
  final BillingScenario scenario;
  final String? notes;
  final DateTime timestamp;
  final bool synced;
  final String? syncError;

  const Reading({
    required this.id,
    required this.meterId,
    required this.meterCode,
    this.value,
    this.photoPath,
    this.ocrText,
    this.ocrSuccess = false,
    this.status = ReadingStatus.pending,
    this.scenario = BillingScenario.meteredOwn,
    this.notes,
    DateTime? timestamp,
    this.synced = false,
    this.syncError,
  }) : this.timestamp = timestamp ?? DateTime.now();

  // --- JSON ---

  Map<String, dynamic> toJson() => {
    'id': id,
    'meter_id': meterId,
    'meter_code': meterCode,
    'value': value,
    'photo_path': photoPath,
    'ocr_text': ocrText,
    'ocr_success': ocrSuccess,
    'status': status.name,
    'scenario': scenario.name,
    'notes': notes,
    'timestamp': timestamp.toIso8601String(),
    'synced': synced,
    'sync_error': syncError,
  };

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
    id: json['id'] as String,
    meterId: json['meter_id'] as int,
    meterCode: json['meter_code'] as String,
    value: (json['value'] as num?)?.toDouble(),
    photoPath: json['photo_path'] as String?,
    ocrText: json['ocr_text'] as String?,
    ocrSuccess: json['ocr_success'] as bool? ?? false,
    status: ReadingStatus.values.firstWhere(
        (s) => s.name == json['status'], orElse: ReadingStatus.pending),
    scenario: BillingScenario.values.firstWhere(
        (s) => s.name == json['scenario'], orElse: BillingScenario.meteredOwn),
    notes: json['notes'] as String?,
    timestamp: DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now(),
    synced: json['synced'] as bool? ?? false,
    syncError: json['sync_error'] as String?,
  );
}