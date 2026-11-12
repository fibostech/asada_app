import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../main.dart' show AsadaColors;
import '../services/pairing_service.dart';

/// Pantalla de pairing inicial (1 sola vez).
/// Se muestra cuando NO hay configuracion guardada.
class PairingPage extends StatefulWidget {
  final PairingService pairingService;
  final VoidCallback onPaired;

  const PairingPage({
    required this.pairingService,
    required this.onPaired,
  });

  @override
  State<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends State<PairingPage> {
  bool _isLoading = false;
  String? _errorMessage;

  // Manual config fields
  final _manualUrlCtrl = TextEditingController();
  final _manualUserCtrl = TextEditingController();
  final _manualPasswordCtrl = TextEditingController();

  // Code entry
  final _codeCtrl = TextEditingController();

  // Scanner
  bool _showScanner = false;
  MobileScannerController? _scannerController;

  @override
  void dispose() {
    _manualUrlCtrl.dispose();
    _manualUserCtrl.dispose();
    _manualPasswordCtrl.dispose();
    _codeCtrl.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AsadaColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
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
              const Text(
                'Configuración inicial',
                style: TextStyle(
                  fontSize: 14,
                  color: AsadaColors.dark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Mensaje de error
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),

              // --- ESCANEAR QR ---
              if (!_showScanner) ...[
                _optionCard(
                  icon: Icons.qr_code_scanner,
                  title: 'Escanear QR',
                  subtitle: 'Apunta al código QR del servidor',
                  color: AsadaColors.primary,
                  onTap: () => setState(() => _showScanner = true),
                ),
                const SizedBox(height: 12),

                // --- INGRESAR CÓDIGO ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.vpn_key,
                                color: AsadaColors.secondary, size: 28),
                            const SizedBox(width: 12),
                            const Text(
                              'Ingresar código',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _codeCtrl,
                          decoration: InputDecoration(
                            labelText: 'Código de 6 dígitos',
                            hintText: '000000',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _claimCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AsadaColors.secondary,
                              foregroundColor: AsadaColors.white,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: AsadaColors.white),
                                  )
                                : const Text('VALIDAR CÓDIGO'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // --- CONFIGURAR MANUALMENTE ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.settings,
                                color: AsadaColors.dark, size: 28),
                            const SizedBox(width: 12),
                            const Text(
                              'Configurar manualmente',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _manualUrlCtrl,
                          decoration: const InputDecoration(
                            labelText: 'URL del Servidor',
                            hintText: 'https://odoo.asa-da.cr',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _manualUserCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            hintText: 'fontanero@example.com',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _manualPasswordCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _manualPair,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AsadaColors.dark,
                              foregroundColor: AsadaColors.white,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: AsadaColors.white),
                                  )
                                : const Text('GUARDAR CONFIGURACIÓN'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // --- SCANNER ACTIVO ---
              if (_showScanner) ...[
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AsadaColors.primary, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: _onQrDetected,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showScanner = false;
                      _scannerController?.dispose();
                      _scannerController = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Cancelar escaneo'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AsadaColors.dark.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AsadaColors.secondary),
            ],
          ),
        ),
      ),
    );
  }

  // --- QR DETECTADO ---
  void _onQrDetected(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null) return;
    final rawValue = barcode.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    // Pausar scanner
    _scannerController?.stop();

    try {
      final Map<String, dynamic> json =
          jsonDecode(rawValue) as Map<String, dynamic>;
      final serverUrl = json['server_url'] as String?;
      final token = json['token'] as String?;

      if (serverUrl == null || token == null) {
        setState(() {
          _errorMessage = 'QR inválido: falta server_url o token';
          _showScanner = false;
        });
        return;
      }

      _claimWithToken(serverUrl, token);
    } catch (e) {
      setState(() {
        _errorMessage = 'QR inválido: no es un JSON válido';
        _showScanner = false;
      });
    }
  }

  // --- RECLAMAR TOKEN (desde QR) ---
  Future<void> _claimWithToken(String serverUrl, String token) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.pairingService.claimToken(serverUrl, token);
      if (!mounted) return;
      widget.onPaired();
    } on PairingException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- RECLAMAR CÓDIGO ---
  Future<void> _claimCode() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'El código debe tener 6 dígitos');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // El código se usa como token; la URL debe ser conocida
    // En producción el código se puede asociar a una URL preconfigurada.
    // Por ahora intentamos con la URL que el usuario haya configurado manualmente
    // o mostramos un campo extra.
    // Como simplificación, el código es el token y la URL se pide aparte.
    if (_manualUrlCtrl.text.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Para usar código, primero ingresa la URL del servidor en "Configurar manualmente"';
      });
      return;
    }

    try {
      await widget.pairingService.claimToken(
          _manualUrlCtrl.text.trim(), code);
      if (!mounted) return;
      widget.onPaired();
    } on PairingException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- PAIRING MANUAL ---
  Future<void> _manualPair() async {
    final url = _manualUrlCtrl.text.trim();
    final user = _manualUserCtrl.text.trim();
    final password = _manualPasswordCtrl.text.trim();

    if (url.isEmpty) {
      setState(() => _errorMessage = 'Ingresa la URL del servidor');
      return;
    }
    if (user.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Ingresa usuario y contraseña');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // En modo manual guardamos URL + token (user/password se usan en login)
    // El token lo generamos localmente como marcador
    try {
      await widget.pairingService.save(
        PairingData(serverUrl: url, token: 'manual_$user'),
      );
      if (!mounted) return;
      widget.onPaired();
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Error al guardar configuración');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
