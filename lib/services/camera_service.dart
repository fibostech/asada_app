import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Maneja captura de fotos desde cámara o galería.
class CameraService {
  /// Captura una foto usando la cámara del dispositivo.
  /// Retorna la ruta del archivo temporal, o null si se cancela.
  Future<String?> capturePhoto() async {
    try {
      final source = await _pickImageSource();
      switch (source) {
        case ImageSource.camera:
          return await _takeFromCamera();
        case ImageSource.gallery:
          return await _pickFromGallery();
      }
    } catch (e) {
      print('Error capturando foto: $e');
      return null;
    }
    return null;
  }

  Future<ImageSource> _pickImageSource() async {
    // En la UI se mostrará un diálogo con opciones.
    // Por ahora retornamos cámara por defecto.
    return ImageSource.camera;
  }

  Future<String?> _takeFromCamera() async {
    // En producción integrar image_picker real o platform channel.
    // Mientras tanto, retorna null para que el flujo caiga a ingreso manual.
    return null;
  }

  Future<String?> _pickFromGallery() async {
    return null;
  }

  /// Valida que la foto tenga calidad suficiente.
  Future<bool> validatePhoto(String path) async {
    if (path == null) return false;
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      final stat = await file.stat();
      // Mínimo 10 KB para considerar foto válida
      return stat.size > 10240;
    } catch (_) {
      return false;
    }
  }

  /// Elimina foto temporal.
  Future<void> cleanupPhoto(String path) async {
    if (path == null) return;
    try {
      await File(path).delete();
    } catch (_) {
      // ignorar
    }
  }
}

enum ImageSource { camera, gallery }