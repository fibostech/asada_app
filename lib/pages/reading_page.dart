import 'package:flutter/material.dart';

import '../models/meter.dart';
import '../bloc/reading_bloc.dart';
import '../widgets/photo_preview.dart';

/// Pantalla de lectura de medidor con cámara + OCR.
class ReadingPage extends StatefulWidget {
  final Meter meter;
  final ReadingBloc readingBloc;

  const ReadingPage({required this.meter, required this.readingBloc});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  double? _manualValue;
  String? _manualNotes;

  @override
  Widget build(BuildContext context) {
    final bloc = widget.readingBloc;
    final meter = widget.meter;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lectura: ${meter.code}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(context, bloc, meter),
    );
  }

  Widget _buildBody(
      BuildContext context, ReadingBloc bloc, Meter meter) {
    switch (bloc.state) {
      case ReadingBlocState.initial:
        return _buildStartView(context, bloc, meter);

      case ReadingBlocState.capturing:
        return const Center(
          child: Column(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 16),
              Text('Abriendo cámara...'),
              SizedBox(height: 8),
              Text(
                'Tome una foto clara del medidor',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        );

      case ReadingBlocState.processingOcr:
        return const Center(
          child: Column(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 16),
              Text('Procesando OCR...'),
              SizedBox(height: 8),
              Text(
                'Leyendo el valor del medidor',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        );

      case ReadingBlocState.manualEntry:
        return _buildManualEntry(context, bloc, meter);

      case ReadingBlocState.completed:
        return _buildCompleted(context, bloc);

      case ReadingBlocState.error:
        return _buildError(context, bloc, meter);

      default:
        return const Center(
          child: Text('Preparando lectura...'),
        );
    }
  }

  Widget _buildStartView(
      BuildContext context, ReadingBloc bloc, Meter meter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.camera_alt, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Medidor: ${meter.code}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (meter.installationAddress != null)
              Text(
                meter.installationAddress!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            const SizedBox(height: 8),
            if (meter.lastReadingValue != null)
              Text(
                'Última lectura: ${meter.lastReadingValue}',
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _doReading(bloc, meter),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, size: 20),
                  SizedBox(width: 8),
                  Text('INICIAR LECTURA'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntry(
      BuildContext context, ReadingBloc bloc, Meter meter) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Foto tomada
          if (bloc.currentPhotoPath != null)
            PhotoPreview(
              photoPath: bloc.currentPhotoPath!,
              ocrText: bloc.ocrText,
              ocrSuccess: false,
            ),
          const SizedBox(height: 16),

          // Mensaje
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, size: 24, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No se pudo leer el medidor automáticamente.\n'
                    'Ingrese el valor manualmente.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Ingreso manual
          TextFormField(
            initialValue: _manualValue?.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Valor del medidor',
              hintText: 'Ej: 12345.6',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {
              _manualValue = double.tryParse(v);
            },
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          TextFormField(
            initialValue: _manualNotes ?? '',
            decoration: const InputDecoration(
              labelText: 'Notas (opcional)',
              hintText: 'Observaciones sobre la lectura',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => _manualNotes = v,
            maxLines: 3,
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () => _saveManual(bloc, meter),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 32,
              ),
            ),
            child: const Text('GUARDAR LECTURA'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleted(BuildContext context, ReadingBloc bloc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              '¡Lectura guardada!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (bloc.ocrText != null)
              Text(
                'Valor OCR: ${bloc.ocrText}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver a la ruta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
      BuildContext context, ReadingBloc bloc, Meter meter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              bloc.errorMessage ?? 'Error en la lectura',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _doReading(bloc, meter),
              child: const Text('Reintentar'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  void _doReading(ReadingBloc bloc, Meter meter) async {
    await bloc.startReading(meter);
  }

  void _saveManual(ReadingBloc bloc, Meter meter) async {
    if (_manualValue == null) return;
    await bloc.saveManualReading(meter, _manualValue!, _manualNotes);
  }
}