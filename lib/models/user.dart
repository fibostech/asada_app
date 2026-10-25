import 'dart:convert';
import 'dart:io';

/// Almacena credenciales offline del fontanero.
class User {
  final int id;
  final String name;
  final String email;
  final String apiKey;
  final String serverUrl;
  final bool isActive;
  final DateTime lastSync;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.apiKey,
    required this.serverUrl,
    this.isActive = true,
    DateTime? lastSync,
  }) : this.lastSync = lastSync ?? DateTime.now();

  // --- JSON ---

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'api_key': apiKey,
    'server_url': serverUrl,
    'is_active': isActive,
    'last_sync': lastSync.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    apiKey: json['api_key'] as String,
    serverUrl: json['server_url'] as String,
    isActive: json['is_active'] as bool? ?? true,
    lastSync: DateTime.tryParse(json['last_sync'] as String?) ?? null,
  );
}