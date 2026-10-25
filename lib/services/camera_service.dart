import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Maneja captura de fotos desde cámara o galería.
class CameraService {
  /// Captura una foto usando la cámara del dispositivo.
  /// Retorna la ruta del archivo temporal, o null si se cancela.
  Future<String?> capturePhoto() async {
    // Envoltorio para image_picker
    // El fontanero puede tomar foto o elegir de galería.
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
    // Integración con image_picker
    // cameraImage(retorna ruta temporal)
    // Por ahora simulamos una ruta.
    return '/tmp/asada_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  Future<String?> _pickFromGallery() async {
    // Integración con image_picker
    return '/tmp/asada_photo_gallery_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  /// Valida que la foto tenga calidad suficiente.
  Future<bool> validatePhoto(String path) async {
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
    try {
      await File(path).delete();
    } catch (_) {
      // ignorar
    }
  }
}

enum ImageSource { camera, gallery }