/// Estado del servicio de un medidor/cliente.
enum ServiceState {
  active,
  suspended,
  disconnected,
  damaged,
  pendingInstallation,
}

class ServiceStatus {
  final int meterId;
  final String meterCode;
  final ServiceState state;
  final String? reason;
  final DateTime changedAt;
  final int? changedByUserId;
  final String? notes;

  ServiceStatus({
    required this.meterId,
    required this.meterCode,
    required this.state,
    this.reason,
    DateTime? changedAt,
    this.changedByUserId,
    this.notes,
  }) : this.changedAt = changedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'meter_id': meterId,
    'meter_code': meterCode,
    'state': state.name,
    'reason': reason,
    'changed_at': changedAt.toIso8601String(),
    'changed_by_user_id': changedByUserId,
    'notes': notes,
  };

  factory ServiceStatus.fromJson(Map<String, dynamic> json) => ServiceStatus(
    meterId: json['meter_id'] as int,
    meterCode: json['meter_code'] as String,
    state: ServiceState.values.firstWhere(
        (s) => s.name == json['state'], orElse: () => ServiceState.active),
    reason: json['reason'] as String?,
    changedAt: DateTime.tryParse(json['changed_at'] as String) ?? DateTime.now(),
    changedByUserId: json['changed_by_user_id'] as int?,
    notes: json['notes'] as String?,
  );
}