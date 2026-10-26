/// Medidor asignado a una ruta.
class Meter {
  final int id;
  final String code;
  final String? installationAddress;
  final String? geoLat;
  final String? geoLng;
  final String? qrCode;
  final String? serialNumber;
  final String status; // active | inactive | damaged
  final int sequence;  // orden en la ruta
  final String routeId;
  final String? lastReadingValue;
  final DateTime? lastReadingDate;
  final int? consumerId;
  final String? consumerName;

  const Meter({
    required this.id,
    required this.code,
    this.installationAddress,
    this.geoLat,
    this.geoLng,
    this.qrCode,
    this.serialNumber,
    this.status = 'active',
    this.sequence = 0,
    required this.routeId,
    this.lastReadingValue,
    this.lastReadingDate,
    this.consumerId,
    this.consumerName,
  });

  // --- JSON ---

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'installation_address': installationAddress,
    'geo_lat': geoLat,
    'geo_lng': geoLng,
    'qr_code': qrCode,
    'serial_number': serialNumber,
    'status': status,
    'sequence': sequence,
    'route_id': routeId,
    'last_reading_value': lastReadingValue,
    'last_reading_date': lastReadingDate?.toIso8601String(),
    'consumer_id': consumerId,
    'consumer_name': consumerName,
  };

  factory Meter.fromJson(Map<String, dynamic> json) => Meter(
    id: json['id'] as int,
    code: json['code'] as String,
    installationAddress: json['installation_address'] as String?,
    geoLat: json['geo_lat'] as String?,
    geoLng: json['geo_lng'] as String?,
    qrCode: json['qr_code'] as String?,
    serialNumber: json['serial_number'] as String?,
    status: json['status'] as String? ?? 'active',
    sequence: json['sequence'] as int? ?? 0,
    routeId: json['route_id'] as String,
    lastReadingValue: json['last_reading_value'] as String?,
    lastReadingDate: json['last_reading_date'] != null
        ? DateTime.tryParse(json['last_reading_date'] as String)
        : null,
    consumerId: json['consumer_id'] as int?,
    consumerName: json['consumer_name'] as String?,
  );
}