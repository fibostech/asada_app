import 'package:flutter/widgets.dart';

/// Vista previa de la foto tomada durante la lectura.
class PhotoPreview extends StatelessWidget {
  final String photoPath;
  final String? ocrText;
  final bool ocrSuccess;

  const PhotoPreview({
    required this.photoPath,
    this.ocrText,
    this.ocrSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Imagen
        ClipRRect(
          borderRadius: BorderRadius.all(12),
          child: Image(
            source: AssetImage(photoPath),
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
          ),
        ),

        SizedBox(height: 8),

        // Resultado OCR
        if (ocrText != null)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ocrSuccess
                  ? Colors.green.shade(0.08)
                  : Colors.orange.shade(0.08),
              borderRadius: BorderRadius.all(8),
            ),
            child: Row(
              children: [
                Icon(
                  ocrSuccess ? Icons.checkCircle : Icons.warning,
                  size: 20,
                  color: ocrSuccess ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ocrSuccess
                        ? 'OCR: $ocrText'
                        : 'OCR: No se pudo leer ($ocrText)',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}