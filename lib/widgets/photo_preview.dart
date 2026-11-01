import 'dart:io';

import 'package:flutter/material.dart';

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
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(photoPath),
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 8),

        // Resultado OCR
        if (ocrText != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ocrSuccess
                  ? Colors.green.withOpacity(0.08)
                  : Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  ocrSuccess ? Icons.check_circle : Icons.warning_amber,
                  size: 20,
                  color: ocrSuccess ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ocrSuccess
                        ? 'OCR: $ocrText'
                        : 'OCR: No se pudo leer ($ocrText)',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}