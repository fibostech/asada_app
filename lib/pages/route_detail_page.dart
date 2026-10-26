import 'package:flutter/material.dart' hide Route;

import '../models/route.dart';
import '../models/meter.dart';
import '../services/camera_service.dart';
import '../services/ocr_service.dart';
import '../services/meter_service.dart';
import '../widgets/meter_card.dart';

/// Pantalla de detalle de ruta con lista de medidores.
class RouteDetailPage extends StatefulWidget {
  final Route route;
  final MeterService meterService;
  final CameraService cameraService;
  final OcrService ocrService;

  const RouteDetailPage({
    required this.route,
    required this.meterService,
    required this.cameraService,
    required this.ocrService,
  });

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  @override
  Widget build(BuildContext context) {
    final route = widget.route;

    return Scaffold(
      appBar: AppBar(
        title: Text(route.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildHeader(context, route),
          for (final meter in route.meters)
            MeterCard(
              meter: meter,
              isRead: meter.status != 'active',
              onTap: () => _startReading(meter),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Route route) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          if (route.description != null)
            Text(
              route.description!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso: ${route.progressPercent.toStringAsFixed(1)}%',
              ),
              Text(
                '${route.completedCount}/${route.meters.length}',
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: route.progressPercent / 100,
          ),
        ],
      ),
    );
  }

  void _startReading(Meter meter) {
    // En producción: construir ReadingBloc y navegar a ReadingPage
  }
}