import 'dart:convert';
import 'dart:io';
import 'dio/dio.dart' as dio;
import 'isar/isar.dart' as isar;

import '../models/user.dart';

/// Servicio de autenticación offline.
/// Almacena credenciales localmente y valida contra Odoo.
class AuthService {
  static const String _CREDENTIALS_KEY = 'asada_saved_credentials';

  final dio.Dio _http;
  final isar.Isar _db;
  User? _currentUser;

  const AuthService({
    required dio.Dio http,
    required isar.Isar db,
  })  : _http = http,
        _db = db;

  /// Intenta login contra Odoo.
  /// [serverUrl] ej. "https://odoo.example.com"
  /// [email] email del usuario
  /// [apiKey] API key generada desde Odoo
  /// Retorna el User autenticado o lanza excepción.
  Future<User> login(String serverUrl, String email, String apiKey) async {
    try {
      final response = await _http.post(
        '$serverUrl/api/asada/v1/auth/login',
        data: {
          'jsonrpc': '2.0',
          'params': {
            'email': email,
            'api_key': apiKey,
          },
        },
      );

      if (response.statusCode != 200) {
        throw AuthException('Error de conexión: ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['error'] != null) {
        throw AuthException(body['error']['message'] ?? 'Error desconocido');
      }

      final result = body['result'] as Map<String, dynamic>;
      final user = User.fromJson({
        'id': result['user_id'],
        'name': result['name'],
        'email': email,
        'api_key': apiKey,
        'server_url': serverUrl,
        'is_active': true,
      });

      // Guardar localmente
      await _saveCredentials(user);
      _currentUser = user;
      return user;
    } on dio.DioException catch (e) {
      // Sin conexión — intentar credenciales guardadas
      final saved = await _loadCredentials();
      if (saved != null &&
          saved.email == email &&
          saved.serverUrl == serverUrl) {
        _currentUser = saved;
        return saved;
      }
      throw AuthException('Sin conexión y sin credenciales guardadas: $e');
    }
  }

  /// Cierra sesión y limpia credenciales.
  Future<void> logout() async {
    _currentUser = null;
    await _db.remove(_CREDENTIALS_KEY);
  }

  /// Recupera el usuario en sesión.
  User? get currentUser => _currentUser;

  /// Verifica si hay sesión activa.
  bool get isLoggedIn => _currentUser != null;

  // --- Persistencia local ---

  Future<void> _saveCredentials(User user) async {
    await _db.put(_CREDENTIALS_KEY, jsonEncode(user.toJson()));
  }

  Future<User?> _loadCredentials() async {
    final data = await _db.get(_CREDENTIALS_KEY) as String?;
    if (data == null) return null;
    try {
      return User.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

class AuthException extends Exception {
  const AuthException(String message) : super(message);
}