import 'package:flutter/material.dart';

import '../models/meter.dart';
import '../models/service_status.dart';
import 'status_badge.dart';

/// Tarjeta resumen de medidor para listas.
class MeterCard extends StatelessWidget {
  final Meter meter;
  final bool isRead;
  final VoidCallback? onTap;

  const MeterCard({required this.meter, this.isRead = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTap?.call(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado: código del medidor + estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    meter.code,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StatusBadge(
                    state: _serviceStateFromString(meter.status),
                    label: _statusLabel(meter.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Dirección / consumidor
              if (meter.installationAddress != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      meter.installationAddress!,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              if (meter.consumerName != null)
                Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      meter.consumerName!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              // Última lectura
              if (meter.lastReadingValue != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Última lectura:', style: TextStyle(fontSize: 12)),
                    Text(
                      '${meter.lastReadingValue}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

              // Badge de leído/no leído
              if (isRead)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '✓ Leído',
                    style: TextStyle(fontSize: 11, color: Colors.green),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  ServiceState _serviceStateFromString(String status) {
    switch (status) {
      case 'active':
        return ServiceState.active;
      case 'suspended':
        return ServiceState.suspended;
      case 'disconnected':
        return ServiceState.disconnected;
      case 'damaged':
        return ServiceState.damaged;
      default:
        return ServiceState.active;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Activo';
      case 'inactive':
        return 'Inactivo';
      case 'damaged':
        return 'Dañado';
      default:
        return status;
    }
  }
}