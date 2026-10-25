import 'package:flutter/widgets.dart';

import '../models/meter.dart';
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
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado: código del medidor + estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    meter.code,
                    style: TextStyle(
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
              SizedBox(height: 8),

              // Dirección / consumidor
              if (meter.installationAddress != null)
                Row(
                  children: [
                    Icon(Icons.locationOn, size: 16),
                    SizedBox(width: 4),
                    Text(
                      meter.installationAddress!,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              if (meter.consumerName != null)
                Row(
                  children: [
                    Icon(Icons.person, size: 16),
                    SizedBox(width: 4),
                    Text(
                      meter.consumerName!,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),

              SizedBox(height: 8),

              // Última lectura
              if (meter.lastReadingValue != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Última lectura:', style: TextStyle(fontSize: 12)),
                    Text(
                      '${meter.lastReadingValue}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

              // Badge de leído/no leído
              if (isRead)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade(0.1),
                    borderRadius: BorderRadius.all(4),
                  ),
                  child: Text(
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