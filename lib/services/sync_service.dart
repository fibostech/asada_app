import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;

import '../models/reading.dart';
import '../models/route.dart';

/// Estado de sincronización.
enum SyncStatus { idle, syncing, completed, failed }

/// Estadísticas de sincronización.
class SyncStats {
  final int total;
  final int success;
  final int failed;
  final int skipped;

  const SyncStats({
    this.total = 0,
    this.success = 0,
    this.failed = 0,
    this.skipped = 0,
  });
}

/// Servicio de sincronización batch.
class SyncService {
  final dio.Dio _http;
  final String _serverUrl;
  final String _apiKey;

  SyncStatus _status = SyncStatus.idle;
  SyncStats _stats = const SyncStats();
  String? _lastError;
  StreamController<SyncProgress>? _progressController;
  late final Stream<SyncProgress> progress;

  SyncService({
    required dio.Dio http,
    required String serverUrl,
    required String apiKey,
  })  : _http = http,
        _serverUrl = serverUrl,
        _apiKey = apiKey {
    _progressController = StreamController<SyncProgress>();
    progress = _progressController!.stream;
  }

  SyncStatus get status => _status;
  SyncStats get stats => _stats;
  String? get lastError => _lastError;

  /// Sincroniza lecturas pendientes en batch.
  Future<SyncResult> syncReadings(List<Reading> pendingReadings) async {
    _status = SyncStatus.syncing;
    _stats = const SyncStats();
    _lastError = null;

    if (pendingReadings.isEmpty) {
      _status = SyncStatus.completed;
      return const SyncResult(success: true, message: 'No hay lecturas pendientes');
    }

    int successCount = 0;
    int failedCount = 0;
    final List<Reading> completed = [];
    final List<Reading> failures = [];

    for (final reading in pendingReadings) {
      try {
        await _syncOne(reading);
        successCount++;
        completed.add(reading);
        _progressController?.add(SyncProgress(
          total: pendingReadings.length,
          current: successCount + failedCount,
          success: successCount,
          failed: failedCount,
          currentMeterCode: reading.meterCode,
        ));
      } catch (e) {
        failedCount++;
        failures.add(reading);
        _progressController?.add(SyncProgress(
          total: pendingReadings.length,
          current: successCount + failedCount,
          success: successCount,
          failed: failedCount,
          currentMeterCode: reading.meterCode,
          error: '$e',
        ));
      }

      // Pequeña pausa entre envíos
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _stats = SyncStats(
      total: pendingReadings.length,
      success: successCount,
      failed: failedCount,
    );
    _status = failedCount > 0 && successCount == 0
        ? SyncStatus.failed
        : SyncStatus.completed;

    _progressController?.close();

    return SyncResult(
      success: failedCount == 0,
      message: 'Sincronizadas: $successCount, Fallidas: $failedCount',
      synced: completed,
      failed: failures,
    );
  }

  Future<void> _syncOne(Reading reading) async {
    final response = await _http.post(
      '$_serverUrl/api/asada/v1/readings/sync',
      data: {
        'jsonrpc': '2.0',
        'params': {
          'reading': reading.toJson(),
        },
      },
      options: dio.Options(
        headers: {
          'API-KEY': _apiKey,
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw SyncException('HTTP ${response.statusCode}');
    }

    final body = jsonDecode(response.data as String) as Map<String, dynamic>;
    if (body['error'] != null) {
      throw SyncException(body['error']['message'] ?? 'Error del servidor');
    }
  }

  /// Descarga rutas asignadas desde el servidor.
  Future<List<Route>> downloadRoutes(int userId) async {
    try {
      final response = await _http.get(
        '$_serverUrl/api/asada/v1/routes',
        queryParameters: {
          'user_id': userId.toString(),
          'status': 'pending',
        },
        options: dio.Options(
          headers: {
            'API-KEY': _apiKey,
          },
        ),
      );

      if (response.statusCode != 200) {
        throw SyncException('Error descargando rutas: ${response.statusCode}');
      }

      final body = jsonDecode(response.data as String) as Map<String, dynamic>;
      if (body['error'] != null) {
        throw SyncException(body['error']['message']);
      }

      final routesData = body['result'] as List<dynamic>? ?? [];
      return routesData
          .cast<Map<String, dynamic>>()
          .map((r) => Route.fromJson(r))
          .toList();
    } on dio.DioException catch (e) {
      throw SyncException('Sin conexión: $e');
    }
  }
}

class SyncProgress {
  final int total;
  final int current;
  final int success;
  final int failed;
  final String? currentMeterCode;
  final String? error;

  const SyncProgress({
    required this.total,
    required this.current,
    required this.success,
    required this.failed,
    this.currentMeterCode,
    this.error,
  });
}

class SyncResult {
  final bool success;
  final String? message;
  final List<Reading> synced;
  final List<Reading> failed;

  const SyncResult({
    required this.success,
    this.message,
    this.synced = const [],
    this.failed = const [],
  });
}

class SyncException implements Exception {
  final String message;
  const SyncException(this.message);

  @override
  String toString() => 'SyncException: $message';
}