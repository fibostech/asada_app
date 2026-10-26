import 'package:flutter/material.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / Título
              const SizedBox(height: 60),
              const Icon(Icons.water_drop, size: 64, color: Colors.blue),
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
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
                        decoration: const InputDecoration(
                          labelText: 'URL del Servidor',
                          hintText: 'https://odoo.asa-da.cr',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => _form.serverUrl = v,
                      ),
                      const SizedBox(height: 12),

                      // Email
                      TextFormField(
                        initialValue: _form.email,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          hintText: 'fontanero@example.com',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => _form.email = v,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      // API Key
                      TextFormField(
                        initialValue: _form.apiKey,
                        decoration: const InputDecoration(
                          labelText: 'API Key',
                          hintText: 'Ingrese su API key de Odoo',
                          border: OutlineInputBorder(),
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

                      // Estado
                      if (bloc.state == AuthBlocState.loading)
                        const Center(
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.10),
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

                      // Botón login
                      ElevatedButton(
                        onPressed: () => _doLogin(bloc),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 48,
                          ),
                        ),
                        child: const Text('INGRESAR'),
                      ),

                      const SizedBox(height: 8),

                      // Modo offline
                      TextButton(
                        onPressed: () => _tryOffline(bloc),
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
    bloc.setErrorMessage('Modo offline: use credenciales guardadas');
  }
}

class _FormData {
  String serverUrl = '';
  String email = '';
  String apiKey = '';
}