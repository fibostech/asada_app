import 'package:dio/dio.dart' as dio;

import 'bloc/auth_bloc.dart';
import 'bloc/route_bloc.dart';
import 'bloc/reading_bloc.dart';
import 'bloc/sync_bloc.dart';
import 'services/auth_service.dart';
import 'services/camera_service.dart';
import 'services/meter_service.dart';
import 'services/ocr_service.dart';
import 'services/sync_service.dart';

/// Inicializador y contenedor de dependencias de la app.
class AppDependencies {
  dio.Dio http = dio.Dio();

  // Servicios
  late final AuthService authService = AuthService(http: http);
  late final CameraService cameraService = CameraService();
  late final MeterService meterService = MeterService();
  late final OcrService ocrService = OcrService();
  late final SyncService syncService = SyncService(
    http: http,
    serverUrl: _serverUrl,
    apiKey: _apiKey,
  );

  // BLoCs
  late final AuthBloc authBloc = AuthBloc(authService: authService);
  late final RouteBloc routeBloc = RouteBloc(
    syncService: syncService,
    meterService: meterService,
  );
  late final ReadingBloc readingBloc = ReadingBloc(
    cameraService: cameraService,
    ocrService: ocrService,
    meterService: meterService,
  );
  late final SyncBloc syncBloc = SyncBloc(
    syncService: syncService,
    meterService: meterService,
  );

  String _serverUrl = '';
  String _apiKey = '';

  /// Configura las credenciales después del login.
  void configureCredentials(String serverUrl, String apiKey) {
    _serverUrl = serverUrl;
    _apiKey = apiKey;
  }

  /// Limpia recursos.
  void dispose() {
    authBloc.dispose();
    routeBloc.dispose();
    readingBloc.dispose();
    syncBloc.dispose();
  }
}