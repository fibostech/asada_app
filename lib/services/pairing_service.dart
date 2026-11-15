import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/pairing.dart';

/// Datos de pairing guardados localmente.
class PairingData {
  final String serverUrl;
  final String token;
  final String? dbName;

  PairingData({required this.serverUrl, required this.token, this.dbName});

  Map<String, dynamic> toJson() => {
        'server_url': serverUrl,
        'token': token,
        if (dbName != null) 'db_name': dbName,
      };

  factory PairingData.fromJson(Map<String, dynamic> json) => PairingData(
        serverUrl: json['server_url'] as String,
        token: json['token'] as String,
        dbName: json['db_name'] as String?,
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
  final Directory _storageDir;

  PairingData? _pairingData;

  /// Crea el servicio.
  ///
  /// [storageDir] es el directorio donde se persiste el archivo JSON.
  /// Si se omite, se usa Directory.systemTemp (ideal para tests).
  PairingService({Directory? storageDir})
      : _storageDir = storageDir ?? Directory.systemTemp;

  /// Ruta completa del archivo de persistencia.
  String get _filePath =>
      '${_storageDir.path}/${_FILE_NAME}';

  /// ¿Ya hay datos de pairing guardados?
  bool get isPaired => _pairingData != null;

  /// URL del servidor guardada.
  String? get serverUrl => _pairingData?.serverUrl;

  /// Token guardado.
  String? get token => _pairingData?.token;

  /// Nombre de base de datos guardado.
  String? get dbName => _pairingData?.dbName;

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
  /// [dbName] nombre de base de datos opcional (desde QR).
  /// Si no se provee, se usa 'asadadev' como fallback.
  Future<String> claimToken(
      String serverUrl, String token, {String? dbName}) async {
    final baseUrl = _normalizeUrl(serverUrl);
    final database = dbName ?? 'asadadev';
    final url = '$baseUrl/api/v1/asada/pairing/claim';
    final body = jsonEncode({'token': token});

    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(url));
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('X-Odoo-Database', database);
      request.write(body);

      final response = await request.close();

      // Leer body completo como string
      final responseBody = await response.transform(utf8.decoder).join();
      final result = jsonDecode(responseBody) as Map<String, dynamic>? ?? {};

      if (result['error'] != null) {
        throw PairingException(
            result['error']['message'] ?? 'Error al reclamar token');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw PairingException(
            'Error HTTP ${response.statusCode}: token inválido');
      }

      // Leer db_name del response body; si no viene, usar el que se pasó
      // o 'asadadev' como fallback
      final effectiveDbName =
          result['db_name'] as String? ?? database;

      // Guardar pairing exitoso
      await save(PairingData(
          serverUrl: baseUrl, token: token, dbName: effectiveDbName));
      return baseUrl;
    } on SocketException catch (_) {
      throw PairingException('Sin conexión al servidor');
    } on HttpException catch (_) {
      throw PairingException('El servidor no responde');
    } on PairingException catch (_) {
      rethrow;
    } catch (e) {
      throw PairingException('Error de conexión: ${e}');
    } finally {
      client.close();
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