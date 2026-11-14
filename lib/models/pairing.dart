/// Datos de pairing persistidos localmente vía Isar/File.
///
/// Almacena la URL del servidor Odoo y el token de emparejamiento
/// de forma durable para que sobrevivan reinicios de la app.
class Pairing {
  final String key;
  final String serverUrl;
  final String token;
  final DateTime createdAt;

  const Pairing({
    required this.key,
    required this.serverUrl,
    required this.token,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'server_url': serverUrl,
        'token': token,
        'created_at': createdAt.toIso8601String(),
      };

  factory Pairing.fromJson(Map<String, dynamic> json) => Pairing(
        key: json['key'] as String? ?? 'asada_pairing_data',
        serverUrl: json['server_url'] as String,
        token: json['token'] as String,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}