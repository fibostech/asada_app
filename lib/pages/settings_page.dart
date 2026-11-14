import 'package:flutter/material.dart';

import '../main.dart' show AsadaColors;
import '../services/pairing_service.dart';

/// Pantalla de ajustes con opción de restablecer configuración.
class SettingsPage extends StatelessWidget {
  final PairingService pairingService;
  final VoidCallback onReset;

  const SettingsPage({
    required this.pairingService,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AsadaColors.lightBg,
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: AsadaColors.primary,
        foregroundColor: AsadaColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información de emparejamiento
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link, color: AsadaColors.secondary),
                      const SizedBox(width: 12),
                      const Text(
                        'Emparejamiento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (pairingService.isPaired) ...[
                    _infoRow('Servidor', pairingService.serverUrl ?? '—'),
                    const SizedBox(height: 4),
                    _infoRow('Base de datos', pairingService.dbName ?? '—'),
                    const SizedBox(height: 4),
                    _infoRow('Token', '••••••••'),
                  ] else
                    const Text(
                      'No hay configuración de emparejamiento.',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botón restablecer
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      SizedBox(width: 12),
                      Text(
                        'Restablecer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esto eliminará la configuración de emparejamiento '
                    'y te redirigirá a la pantalla de configuración inicial.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmReset(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('RESTABLECER CONFIGURACIÓN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: AsadaColors.dark.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer configuración'),
        content: const Text(
          'Se perderá la configuración de emparejamiento.\n'
          '¿Estás seguro de continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await pairingService.clear();
              onReset();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('RESTABLECER'),
          ),
        ],
      ),
    );
  }
}
