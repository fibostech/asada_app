import 'package:flutter/widgets.dart';

import '../bloc/sync_bloc.dart';
import '../services/sync_service.dart';

/// Pantalla de sincronización batch.
class SyncPage extends StatefulWidget {
  final SyncBloc syncBloc;

  const SyncPage({required this.syncBloc});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  @override
  Widget build(BuildContext context) {
    final bloc = widget.syncBloc;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sincronización'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          cross: CrossAxisAlignment.stretch,
          children: [
            // Estado actual
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _statusIcon(bloc.status),
                          size: 32,
                          color: _statusColor(bloc.status),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _statusLabel(bloc.status),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    if (bloc.isSyncing) ...[
                      LinearProgressIndicator(),
                      SizedBox(height: 8),
                    ],

                    // Estadísticas
                    if (bloc.stats.total > 0) ...[
                      SizedBox(height: 8),
                      Text(
                        'Total: ${bloc.stats.total} | '
                        'Exitosas: ${bloc.stats.success} | '
                        'Fallidas: ${bloc.stats.failed}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Botón sincronizar
            Center(
              child: ElevatedButton(
                onPressed: bloc.isSyncing ? null : () => _doSync(bloc),
                child: Row(
                  children: [
                    Icon(Icons.sync, size: 20),
                    SizedBox(width: 8),
                    Text(
                      bloc.isSyncing
                          ? 'SINCRONIZANDO...'
                          : 'SINCRONIZAR AHORA',
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 32,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Historial
            Text(
              'Últimas sincronizaciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            // Placeholder para historial
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Las sincronizaciones completadas aparecerán aquí.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _doSync(SyncBloc bloc) async {
    await bloc.syncAll();
  }

  IconData _statusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Icons.cloudDone;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.completed:
        return Icons.checkCircle;
      case SyncStatus.failed:
        return Icons.error;
    }
  }

  Color _statusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Colors.grey;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.completed:
        return Colors.green;
      case SyncStatus.failed:
        return Colors.red;
    }
  }

  String _statusLabel(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'En espera';
      case SyncStatus.syncing:
        return 'Sincronizando...';
      case SyncStatus.completed:
        return 'Completado';
      case SyncStatus.failed:
        return 'Error en sincronización';
    }
  }
}