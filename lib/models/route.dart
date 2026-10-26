import 'meter.dart';

/// Ruta de medidores asignada a un fontanero.
class Route {
  final String id;
  final String name;
  final String? description;
  final int? assignedUserId;
  final String? assignedUserName;
  final List<Meter> meters;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status; // pending | in_progress | completed

  Route({
    required this.id,
    required this.name,
    this.description,
    this.assignedUserId,
    this.assignedUserName,
    this.meters = const [],
    DateTime? createdAt,
    this.updatedAt,
    this.status = 'pending',
  }) : this.createdAt = createdAt ?? DateTime.now();

  int get completedCount =>
      meters.where((m) => m.status == 'completed').length;

  int get pendingCount =>
      meters.where((m) => m.status == 'active').length;

  double get progressPercent =>
      meters.isEmpty ? 0 : (completedCount / meters.length * 100);

  // --- JSON ---

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'assigned_user_id': assignedUserId,
    'assigned_user_name': assignedUserName,
    'meters': meters.map((m) => m.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'status': status,
  };

  factory Route.fromJson(Map<String, dynamic> json) => Route(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    assignedUserId: json['assigned_user_id'] as int?,
    assignedUserName: json['assigned_user_name'] as String?,
    meters: (json['meters'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map((m) => Meter.fromJson(m))
            .toList(),
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
    updatedAt: json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'] as String)
        : null,
    status: json['status'] as String? ?? 'pending',
  );
}