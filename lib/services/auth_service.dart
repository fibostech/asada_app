import 'dart:convert';
import 'package:dio/dio.dart' as dio;

import '../models/user.dart';

/// Servicio de autenticación offline.
/// Almacena credenciales localmente (API key ofuscada) y valida contra Odoo.
/// En producción integrar flutter_secure_storage o platform keychain.
class AuthService {
  static const String _CREDENTIALS_KEY = 'asada_saved_credentials';
  static const String _DEFAULT_DATABASE = 'demo';

  // Almacén local en memoria (skeleton). En producción se persiste
  // con Isar/secure storage.
  static final Map<String, String> _localStore = {};

  final dio.Dio _http;
  User? _currentUser;

  AuthService({
    required dio.Dio http,
  }) : _http = http;

  /// Intenta login contra Odoo.
  /// [serverUrl] ej. "https://odoo.example.com"
  /// [email] email del usuario
  /// [apiKey] API key generada desde Odoo
  /// [password] contraseña del usuario (usa apiKey por defecto)
  /// [database] base de datos Odoo (por defecto "demo")
  /// Retorna el User autenticado o lanza excepción.
  Future<User> login(
    String serverUrl,
    String email,
    String apiKey, {
    String? password,
    String database = _DEFAULT_DATABASE,
  }) async {
    final baseUrl = _normalizeUrl(serverUrl);
    try {
      final response = await _http.post(
        '$baseUrl/api/v1/asada/login',
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Odoo-Database': database,
          },
        ),
        data: {
          'login': email,
          'password': password ?? apiKey,
          'api_key': apiKey,
        },
      );

      // Fallback defensivo (Dio ya lanza DioException para códigos != 2xx).
      if (response.statusCode != 200) {
        throw AuthException(
          _describeHttpError(response.statusCode, 'Error HTTP ${response.statusCode}'),
        );
      }

      // Dio 5 entrega el JSON ya decodificado (Map), no un String.
      final Map<String, dynamic> body = response.data;
      if (body['error'] != null) {
        throw AuthException(body['error']['message'] ?? 'Error desconocido');
      }

      final user = User.fromJson({
        'id': body['user_id'],
        'name': body['nombre'] ?? '',
        'email': email,
        'api_key': apiKey,
        'server_url': baseUrl,
        'is_active': true,
      });

      // Guardar localmente con API key ofuscada
      await _saveCredentials(user);
      _currentUser = user;
      return user;
    } on dio.DioException catch (e) {
      // Error HTTP: el servidor respondió con un código de error.
      if (e.response != null) {
        throw AuthException(
          _describeHttpError(e.response!.statusCode, e.message ?? 'Error desconocido'),
        );
      }

      // Sin conexión — intentar credenciales guardadas
      final saved = await _loadCredentials();
      if (saved != null &&
          saved.email == email &&
          saved.serverUrl == baseUrl) {
        // Verificar API key contra la guardada
        if (saved.apiKey == apiKey) {
          _currentUser = saved;
          return saved;
        }
      }

      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        throw AuthException('El servidor no responde');
      }
      throw AuthException('Sin conexión y sin credenciales guardadas: $e');
    }
  }

  /// Normaliza la URL del servidor: recorta espacios y elimina el slash final.
  static String _normalizeUrl(String url) {
    var normalized = url.trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  /// Traduce códigos HTTP a mensajes legibles para el usuario.
  static String _describeHttpError(int? statusCode, String fallback) {
    switch (statusCode) {
      case 404:
        return 'Base de datos no encontrada o URL incorrecta';
      case 401:
        return 'Credenciales inválidas (verifica email, password y API key)';
      case 500:
        return 'Error del servidor';
      default:
        return fallback;
    }
  }

  /// Cierra sesión y limpia credenciales.
  Future<void> logout() async {
    _currentUser = null;
    _localStore.remove(_CREDENTIALS_KEY);
  }

  /// Recupera el usuario en sesión.
  User? get currentUser => _currentUser;

  /// Verifica si hay sesión activa.
  bool get isLoggedIn => _currentUser != null;

  // --- Persistencia local con ofuscación ---

  /// Codifica texto en base64 (ofuscación básica).
  /// En producción usar cifrado simétrico con clave derivada del dispositivo.
  static String _obfuscate(String text) {
    return base64Encode(utf8.encode(text));
  }

  /// Decodifica texto ofuscado.
  static String _deobfuscate(String encoded) {
    return utf8.decode(base64Decode(encoded));
  }

  Future<void> _saveCredentials(User user) async {
    // Ofuscar API key antes de guardar
    final safeUser = User(
      id: user.id,
      name: user.name,
      email: user.email,
      apiKey: _obfuscate(user.apiKey),
      serverUrl: user.serverUrl,
      isActive: user.isActive,
      lastSync: user.lastSync,
    );
    _localStore[_CREDENTIALS_KEY] = jsonEncode(safeUser.toJson());
  }

  Future<User?> _loadCredentials() async {
    final data = _localStore[_CREDENTIALS_KEY];
    if (data == null) return null;
    try {
      final user = User.fromJson(jsonDecode(data) as Map<String, dynamic>);
      // Desofuscar API key
      final deobfuscated = User(
        id: user.id,
        name: user.name,
        email: user.email,
        apiKey: _deobfuscate(user.apiKey),
        serverUrl: user.serverUrl,
        isActive: user.isActive,
        lastSync: user.lastSync,
      );
      return deobfuscated;
    } catch (_) {
      return null;
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
