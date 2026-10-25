import 'package:flutter/widgets.dart';

import '../models/meter.dart';
import '../models/reading.dart';
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
  bool _showManualEntry = false;

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
        return _buildStartView(context, meter);

      case ReadingBlocState.capturing:
        return Center(
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
        return Center(
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
        return Center(
          child: Text('Preparando lectura...'),
        );
    }
  }

  Widget _buildStartView(BuildContext context, Meter meter) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.cameraAlt, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Medidor: ${meter.code}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (meter.installationAddress != null)
              Text(
                meter.installationAddress!,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            SizedBox(height: 8),
            if (meter.lastReadingValue != null)
              Text(
                'Última lectura: ${meter.lastReadingValue}',
                style: TextStyle(fontSize: 14),
              ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _doReading(bloc, meter),
              child: Row(
                children: [
                  Icon(Icons.cameraAlt, size: 20),
                  SizedBox(width: 8),
                  Text('INICIAR LECTURA'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
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
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Foto tomada
          if (bloc.currentPhotoPath != null)
            PhotoPreview(
              photoPath: bloc.currentPhotoPath!,
              ocrText: bloc.ocrText,
              ocrSuccess: false,
            ),
          SizedBox(height: 16),

          // Mensaje
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.all(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, size: 24, color: Colors.orange),
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

          SizedBox(height: 16),

          // Ingreso manual
          TextField(
            decoration: InputDecoration(
              labelText: 'Valor del medidor',
              hintText: 'Ej: 12345.6',
            ),
            initialValue: _manualValue?.toString() ?? '',
            onChanged: (v) {
              _manualValue = double.tryParse(v);
            },
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),

          TextField(
            decoration: InputDecoration(
              labelText: 'Notas (opcional)',
              hintText: 'Observaciones sobre la lectura',
            ),
            initialValue: _manualNotes ?? '',
            onChanged: (v) => _manualNotes = v,
            maxLines: 3,
          ),

          SizedBox(height: 20),

          ElevatedButton(
            onPressed: () => _saveManual(bloc, meter),
            child: Text('GUARDAR LECTURA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleted(BuildContext context, ReadingBloc bloc) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.checkCircle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              '¡Lectura guardada!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            if (bloc.ocrText != null)
              Text(
                'Valor OCR: ${bloc.ocrText}',
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Volver a la ruta'),
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
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            SizedBox(height: 12),
            Text(
              bloc.errorMessage ?? 'Error en la lectura',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _doReading(bloc, meter),
              child: Text('Reintentar'),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  void _doReading(ReadingBloc bloc, Meter meter) async {
    await bloc.startReading(meter);
    if (bloc.state == ReadingBlocState.manualEntry) {
      _showManualEntry = true;
    }
  }

  void _saveManual(ReadingBloc bloc, Meter meter) async {
    if (_manualValue == null) return;
    await bloc.saveManualReading(meter, _manualValue!, _manualNotes);
  }
}