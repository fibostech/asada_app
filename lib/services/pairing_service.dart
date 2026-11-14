import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;

import '../models/pairing.dart';

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
///
/// Almacena server_url y token de forma persistente en disco usando
/// dart:io File, para que los datos sobrevivan reinicios de la app.
/// El modelo [Pairing] queda preparado para migrar a Isar Database
/// cuando se configure el generador de Isar.
class PairingService {
  static const String _FILE_NAME = 'asada_pairing.json';
  final dio.Dio _http;
  final Directory _storageDir;

  PairingData? _pairingData;

  /// Crea el servicio.
  ///
  /// [storageDir] es el directorio donde se persiste el archivo JSON.
  /// Si se omite, se usa Directory.systemTemp (ideal para tests).
  PairingService({
    required dio.Dio http,
    Directory? storageDir,
  })  : _http = http,
        _storageDir = storageDir ?? Directory.systemTemp;

  /// Ruta completa del archivo de persistencia.
  String get _filePath =>
      '${_storageDir.path}/${_FILE_NAME}';

  /// ¿Ya hay datos de pairing guardados?
  bool get isPaired => _pairingData != null;

  /// URL del servidor guardada.
  String? get serverUrl => _pairingData?.serverUrl;

  /// Token guardado.
  String? get token => _pairingData?.token;

  /// Carga datos de pairing desde el archivo persistente.
  Future<void> load() async {
    final file = File(_filePath);
    if (!await file.exists()) return;
    try {
      final raw = await file.readAsString();
      if (raw.isEmpty) return;
      _pairingData =
          PairingData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      _pairingData = null;
    }
  }

  /// Guarda datos de pairing en disco (sobreescribe).
  Future<void> save(PairingData data) async {
    _pairingData = data;
    // Asegurar que el directorio existe
    await _storageDir.create(recursive: true);
    await File(_filePath).writeAsString(jsonEncode(data.toJson()));
  }

  /// Elimina el archivo de persistencia.
  Future<void> clear() async {
    _pairingData = null;
    final file = File(_filePath);
    if (await file.exists()) {
      await file.delete();
    }
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
          'X-Odoo-Database': 'asadadev',
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