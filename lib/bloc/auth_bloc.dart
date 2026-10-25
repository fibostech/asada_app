import 'dart:async';
import 'dio/dio.dart' as dio;
import 'isar/isar.dart' as isar;

import '../models/user.dart';
import '../services/auth_service.dart';

/// Estados del BLoC de autenticación.
enum AuthBlocState {
  initial,
  loading,
  authenticated,
  error,
  offlineMode,
}

/// BLoC de autenticación.
class AuthBloc {
  final AuthService _authService;
  AuthBlocState _state = AuthBlocState.initial;
  String? _errorMessage;
  StreamController<AuthBlocState>? _stateController;
  final Stream<AuthBlocState> stateChanges;

  const AuthBloc({
    required AuthService authService,
  })  : _authService = authService,
        stateChanges =
            (_stateController = StreamController<AuthBlocState>()).stream;

  AuthBlocState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;

  /// Inicia sesión.
  Future<void> login(String serverUrl, String email, String apiKey) async {
    _state = AuthBlocState.loading;
    _errorMessage = null;
    _emitState();

    try {
      await _authService.login(serverUrl, email, apiKey);
      _state = AuthBlocState.authenticated;
    } on AuthException catch (e) {
      _state = AuthBlocState.error;
      _errorMessage = e.message;
    } catch (e) {
      // Sin conexión — modo offline
      _state = AuthBlocState.offlineMode;
      _errorMessage = 'Sin conexión. Usando credenciales guardadas.';
    }

    _emitState();
  }

  /// Cierra sesión.
  Future<void> logout() async {
    await _authService.logout();
    _state = AuthBlocState.initial;
    _errorMessage = null;
    _emitState();
  }

  void _emitState() {
    _stateController?.add(_state);
  }

  void dispose() {
    _stateController?.close();
  }
}