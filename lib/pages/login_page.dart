import 'package:flutter/widgets.dart';

import '../bloc/auth_bloc.dart';

/// Pantalla de login offline.
class LoginPage extends StatefulWidget {
  final AuthBloc authBloc;

  const LoginPage({required this.authBloc});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _FormData _form = _FormData();
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final bloc = widget.authBloc;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / Título
              SizedBox(height: 60),
              Icon(Icons.waterDrop, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'ASADA App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Sistema de Lectura para Fontaneros',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32),

              // Formulario
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Servidor
                      TextField(
                        label: 'URL del Servidor',
                        hint: 'https://odoo.asa-da.cr',
                        value: _form.serverUrl,
                        onChanged: (v) => _form.serverUrl = v,
                      ),
                      SizedBox(height: 12),

                      // Email
                      TextField(
                        label: 'Correo Electrónico',
                        hint: 'fontanero@example.com',
                        value: _form.email,
                        onChanged: (v) => _form.email = v,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 12),

                      // API Key
                      TextField(
                        label: 'API Key',
                        hint: 'Ingrese su API key de Odoo',
                        value: _form.apiKey,
                        onChanged: (v) => _form.apiKey = v,
                        obscureText: !_showPassword,
                      ),
                      SizedBox(height: 8),

                      // Mostrar API Key
                      Row(
                        children: [
                          Checkbox(
                            value: _showPassword,
                            onChanged: (v) => _showPassword = v,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Mostrar API Key',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Estado
                      if (bloc.state == AuthBlocState.loading)
                        Center(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(),
                              ),
                              SizedBox(width: 12),
                              Text('Conectando...'),
                            ],
                          ),
                        ),

                      if (bloc.errorMessage != null)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade(0.08),
                            borderRadius: BorderRadius.all(8),
                          ),
                          child: Text(
                            bloc.errorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),

                      SizedBox(height: 12),

                      // Botón login
                      ElevatedButton(
                        onPressed: () => _doLogin(bloc),
                        child: Text('INGRESAR'),
                        style: ElevatedButtonStyle(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 48,
                          ),
                        ),
                      ),

                      SizedBox(height: 8),

                      // Modo offline
                      TextButton(
                        onPressed: () => _tryOffline(bloc),
                        child: Text(
                          'Usar modo offline',
                          style: TextStyle(
                            color: Colors.grey,
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

  void _doLogin(AuthBloc bloc) async {
    if (_form.serverUrl.isEmpty ||
        _form.email.isEmpty ||
        _form.apiKey.isEmpty) {
      return;
    }
    await bloc.login(_form.serverUrl, _form.email, _form.apiKey);
  }

  void _tryOffline(AuthBloc bloc) async {
    // Intenta con credenciales guardadas
    // Por ahora muestra mensaje
    bloc._errorMessage = 'Modo offline: use credenciales guardadas';
  }
}

class _FormData {
  String serverUrl = '';
  String email = '';
  String apiKey = '';
}