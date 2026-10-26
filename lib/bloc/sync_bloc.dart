import 'dart:async';

import '../services/sync_service.dart';
import '../services/meter_service.dart';

/// BLoC de sincronización.
class SyncBloc {
  final SyncService _syncService;
  final MeterService _meterService;
  bool _syncing = false;
  StreamController<SyncProgress>? _progressController;
  late final Stream<SyncProgress> progress;

  SyncBloc({
    required SyncService syncService,
    required MeterService meterService,
  })  : _syncService = syncService,
        _meterService = meterService {
    _progressController = StreamController<SyncProgress>();
    progress = _progressController!.stream;
  }

  bool get isSyncing => _syncing;
  SyncStatus get status => _syncService.status;
  SyncStats get stats => _syncService.stats;

  /// Ejecuta sincronización completa.
  Future<SyncResult> syncAll() async {
    if (_syncing) {
      return SyncResult(success: false, message: 'Ya sincronizando');
    }

    _syncing = true;
    final pending = _meterService.pendingReadings;

    if (pending.isEmpty) {
      _syncing = false;
      return SyncResult(success: true, message: 'No hay lecturas pendientes');
    }

    final result = await _syncService.syncReadings(pending);

    if (result.success || result.synced.isNotEmpty) {
      await _meterService.markAsSynced(result.synced);
    }

    _syncing = false;
    _progressController?.close();
    return result;
  }

  void dispose() {
    _progressController?.close();
  }
}