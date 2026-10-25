import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Servicio de OCR para leer medidores desde foto.
/// Estrategia: primero intenta OCR offline (Tesseract/Mobile), 
/// si no disponible, usa API remota.
class OcrService {
  final String? _serverUrl;
  final String? _apiKey;
  bool _useRemoteOcr = false;

  const OcrService({String? serverUrl, String? apiKey})
      : _serverUrl = serverUrl,
        _apiKey = apiKey;

  /// Ejecuta OCR sobre la foto y retorna el texto detectado.
  /// Retorna null si no pudo leer nada.
  Future<String?> performOcr(String photoPath) async {
    String? text;

    // 1. Intentar OCR offline
    text = await _offlineOcr(photoPath);
    if (text != null && text.trim().isNotEmpty) {
      return text.trim();
    }

    // 2. Fallback a OCR remoto
    if (_serverUrl != null && _apiKey != null) {
      text = await _remoteOcr(photoPath);
      if (text != null && text.trim().isNotEmpty) {
        _useRemoteOcr = true;
        return text.trim();
      }
    }

    return null;
  }

  /// OCR offline usando Motor de reconocimiento integrado.
  Future<String?> _offlineOcr(String photoPath) async {
    try {
      // En producción se integraría Tesseract o ML Kit.
      // Simulación: extrae metadatos de la imagen.
      final file = File(photoPath);
      if (!await file.exists()) return null;

      // Placeholder para OCR real:
      // En una implementación real llamaríamos a un modelo ONNX/TFLite
      // o a Tesseract vía platform channel.
      return null;
    } catch (_) {
      return null;
    }
  }

  /// OCR remoto vía API de Odoo.
  Future<String?> _remoteOcr(String photoPath) async {
    try {
      // En producción sería una llamada HTTP multipart
      // con la imagen al endpoint de Odoo.
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Valida formato de lectura (enteros y decimales).
  static bool validateReading(String text) {
    if (text == null || text.trim().isEmpty) return false;
    // Patrón: dígitos con punto decimal opcional
    final pattern = RegExp(r'^\d+\.?\d*$');
    return pattern.hasMatch(text.trim());
  }

  /// Extrae solo dígitos y punto decimal.
  static String sanitizeReading(String text) {
    if (text == null) return '';
    return text.replaceAll(RegExp(r'[^\d.]'), '');
  }
}