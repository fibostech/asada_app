import 'package:flutter/widgets.dart';

import '../models/route.dart';
import '../models/meter.dart';
import '../bloc/reading_bloc.dart';
import '../services/camera_service.dart';
import '../services/ocr_service.dart';
import '../services/meter_service.dart';
import '../widgets/meter_card.dart';
import 'reading_page.dart';

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
          _buildHeader(route),
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

  Widget _buildHeader(Route route) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          if (route.description != null)
            Text(
              route.description!,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          SizedBox(height: 8),
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
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: route.progressPercent / 100,
          ),
        ],
      ),
    );
  }

  void _startReading(Meter meter) {
    final readingBloc = ReadingBloc(
      cameraService: widget.cameraService,
      ocrService: widget.ocrService,
      meterService: widget.meterService,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingPage(
          meter: meter,
          readingBloc: readingBloc,
        ),
      ),
    );
  }
}