import 'dart:convert';
import 'package:dio/dio.dart' as dio;

/// Datos de pairing guardados localmente.
class PairingData {
  final String serverUrl;
  final String token;

  PairingData({required this.serverUrl, required this.token});

  Map<String, dynamic> toJson() => {
        'server_url': serverUrl,
        'token': token,
      };

  factory PairingData.fromJson(Map<String, dynamic> json) => PairingData(
        serverUrl: json['server_url'] as String,
        token: json['token'] as String,
      );
}

/// Servicio de pairing: emparejamiento inicial con el servidor Odoo.
/// Almacena server_url y token localmente en memoria (skeleton).
/// En producción se persiste con Isar/secure storage.
class PairingService {
  static const String _PAIRING_KEY = 'asada_pairing_data';
  static final Map<String, String> _localStore = {};

  final dio.Dio _http;

  PairingData? _pairingData;

  PairingService({required dio.Dio http}) : _http = http;

  /// ¿Ya hay datos de pairing guardados?
  bool get isPaired => _pairingData != null;

  /// URL del servidor guardada.
  String? get serverUrl => _pairingData?.serverUrl;

  /// Token guardado.
  String? get token => _pairingData?.token;

  /// Carga datos de pairing desde almacén local.
  Future<void> load() async {
    final data = _localStore[_PAIRING_KEY];
    if (data == null) return;
    try {
      _pairingData =
          PairingData.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      _pairingData = null;
    }
  }

  /// Guarda datos de pairing.
  Future<void> save(PairingData data) async {
    _pairingData = data;
    _localStore[_PAIRING_KEY] = jsonEncode(data.toJson());
  }

  /// Limpia datos de pairing.
  Future<void> clear() async {
    _pairingData = null;
    _localStore.remove(_PAIRING_KEY);
  }

  /// Reclama un token de pairing contra el servidor.
  /// Retorna la URL del servidor si el reclamo es exitoso.
  Future<String> claimToken(String serverUrl, String token) async {
    final baseUrl = _normalizeUrl(serverUrl);
    try {
      final response = await _http.post(
        '$baseUrl/api/v1/asada/pairing/claim',
        options: dio.Options(headers: {
          'Content-Type': 'application/json',
        }),
        data: {
          'token': token,
        },
      );

      if (response.statusCode != 200) {
        throw PairingException(
            'Error HTTP ${response.statusCode}: token inválido');
      }

      final body = response.data as Map<String, dynamic>? ?? {};
      if (body['error'] != null) {
        throw PairingException(
            body['error']['message'] ?? 'Error al reclamar token');
      }

      // Guardar pairing exitoso
      await save(PairingData(serverUrl: baseUrl, token: token));
      return baseUrl;
    } on dio.DioException catch (e) {
      if (e.response != null) {
        throw PairingException(
            'Error del servidor (${e.response?.statusCode})');
      }
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        throw PairingException('El servidor no responde');
      }
      throw PairingException('Sin conexión al servidor');
    }
  }

  /// Normaliza URL del servidor.
  static String _normalizeUrl(String url) {
    var normalized = url.trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}

class PairingException implements Exception {
  final String message;
  const PairingException(this.message);

  @override
  String toString() => 'PairingException: $message';
}
