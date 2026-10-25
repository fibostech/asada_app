import 'dart:async';

import '../models/route.dart';
import '../services/sync_service.dart';
import '../services/meter_service.dart';

/// Estados del BLoC de rutas.
enum RouteBlocState {
  initial,
  loading,
  ready,
  error,
}

/// BLoC de gestión de rutas.
class RouteBloc {
  final SyncService _syncService;
  final MeterService _meterService;
  RouteBlocState _state = RouteBlocState.initial;
  String? _errorMessage;
  StreamController<RouteBlocState>? _stateController;
  final Stream<RouteBlocState> stateChanges;

  RouteBloc({
    required SyncService syncService,
    required MeterService meterService,
  })  : _syncService = syncService,
        _meterService = meterService,
        stateChanges =
            (_stateController = StreamController<RouteBlocState>()).stream;

  RouteBlocState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Route> get routes => _meterService.localRoutes;

  /// Descarga rutas del servidor.
  Future<void> downloadRoutes(int userId) async {
    _state = RouteBlocState.loading;
    _errorMessage = null;
    _emitState();

    try {
      final routes = await _syncService.downloadRoutes(userId);
      _meterService.setRoutes(routes);
      _state = routes.isEmpty
          ? RouteBlocState.ready
          : RouteBlocState.ready;
    } catch (e) {
      _state = RouteBlocState.error;
      _errorMessage = 'Error descargando rutas: $e';
    }

    _emitState();
  }

  void _emitState() {
    _stateController?.add(_state);
  }

  void dispose() {
    _stateController?.close();
  }
}