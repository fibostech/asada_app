import 'dart:async';

import 'package:flutter/material.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/route_bloc.dart';
import '../main.dart' show AsadaColors;
import 'route_list_page.dart';

/// Pantalla de login offline.
class LoginPage extends StatefulWidget {
  final AuthBloc authBloc;
  final RouteBloc routeBloc;

  const LoginPage({required this.authBloc, required this.routeBloc});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _FormData _form = _FormData();
  bool _showPassword = false;
  bool _isLoading = false;
  Timer? _timeoutTimer;
  BuildContext? _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    final bloc = widget.authBloc;

    return Scaffold(
      backgroundColor: AsadaColors.lightBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / Título
              const SizedBox(height: 60),
              const Icon(Icons.water_drop, size: 64, color: AsadaColors.primary),
              const SizedBox(height: 16),
              const Text(
                'ASADA App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Sistema de Lectura para Fontaneros',
                style: TextStyle(fontSize: 14, color: AsadaColors.dark.withValues(alpha: 0.65)),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Formulario
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Servidor
                      TextFormField(
                        initialValue: _form.serverUrl,
                        decoration: InputDecoration(
                          labelText: 'URL del Servidor',
                          hintText: 'https://odoo.asa-da.cr',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AsadaColors.secondary,
                              width: 1.0,
                            ),
                          ),
                        ),
                        onChanged: (v) => _form.serverUrl = v,
                      ),
                      const SizedBox(height: 12),

                      // Email
                      TextFormField(
                        initialValue: _form.email,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          hintText: 'fontanero@example.com',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AsadaColors.secondary,
                              width: 1.0,
                            ),
                          ),
                        ),
                        onChanged: (v) => _form.email = v,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      // API Key
                      TextFormField(
                        initialValue: _form.apiKey,
                        decoration: InputDecoration(
                          labelText: 'API Key',
                          hintText: 'Ingrese su API key de Odoo',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AsadaColors.secondary,
                              width: 1.0,
                            ),
                          ),
                        ),
                        onChanged: (v) => _form.apiKey = v,
                        obscureText: !_showPassword,
                      ),
                      const SizedBox(height: 8),

                      // Mostrar API Key
                      Row(
                        children: [
                          Checkbox(
                            value: _showPassword,
                            onChanged: (v) =>
                                setState(() => _showPassword = v ?? false),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Mostrar API Key',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Mensaje de error
                      if (bloc.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bloc.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Botón login con indicador de carga
                      ElevatedButton(
                        onPressed: _isLoading ? null : () => _doLogin(bloc),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AsadaColors.primary,
                          foregroundColor: AsadaColors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 48,
                          ),
                        ),
                        child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AsadaColors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Conectando...'),
                              ],
                            )
                          : const Text('INGRESAR'),
                      ),

                      const SizedBox(height: 8),

                      // Modo offline
                      TextButton(
                        onPressed: _isLoading ? null : () => _tryOffline(bloc),
                        child: Text(
                          'Usar modo offline',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _doLogin(AuthBloc bloc) async {
    if (_isLoading) return;
    if (_form.serverUrl.isEmpty ||
        _form.email.isEmpty ||
        _form.apiKey.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    // Timeout de 15 segundos
    bool timedOut = false;
    _timeoutTimer = Timer(Duration(seconds: 15), () {
      timedOut = true;
      bloc.setErrorMessage('Tiempo de espera agotado');
      setState(() => _isLoading = false);
    });

    try {
      await bloc.login(_form.serverUrl, _form.email, _form.apiKey);

      if (timedOut) return;

      _timeoutTimer?.cancel();

      if (bloc.state == AuthBlocState.authenticated) {
        Navigator.push(
          _context!,
          MaterialPageRoute(
            builder: (_) => RouteListPage(routeBloc: widget.routeBloc),
          ),
        );
      } else if (bloc.state == AuthBlocState.error) {
        _mapErrorMessage(bloc);
      }
    } catch (e) {
      if (!timedOut) {
        bloc.setErrorMessage('Error de conexión');
      }
    } finally {
      if (!timedOut) {
        setState(() => _isLoading = false);
      }
      _timeoutTimer?.cancel();
      _timeoutTimer = null;
    }
  }

  void _mapErrorMessage(AuthBloc bloc) {
    final msg = bloc.errorMessage ?? '';
    String displayMsg;
    if (msg.contains('conexión') ||
        msg.contains('connect') ||
        msg.contains('Sin conexión')) {
      displayMsg = 'Error de conexión';
    } else if (msg.contains('401') ||
        msg.contains('unauthorized') ||
        msg.contains('credencial') ||
        msg.contains('Invalid')) {
      displayMsg = 'Credenciales inválidas';
    } else if (msg.contains('URL') ||
        msg.contains('url') ||
        msg.contains('servidor') ||
        msg.contains('server')) {
      displayMsg = 'URL incorrecta';
    } else {
      displayMsg = msg;
    }
    bloc.setErrorMessage(displayMsg);
  }

  void _tryOffline(AuthBloc bloc) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await bloc.login('', '', '');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _FormData {
  String serverUrl = '';
  String email = '';
  String apiKey = '';
}