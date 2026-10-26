/// Servicio de OCR para leer medidores desde foto.
/// Estrategia: primero intenta OCR offline (Tesseract/ML Kit),
/// si no disponible, usa API remota.
/// Mientras no se integre un motor real, retorna null para
/// que el flujo caiga a ingreso manual.
class OcrService {
  OcrService();

  /// Ejecuta OCR sobre la foto y retorna el texto detectado.
  /// Retorna null si no pudo leer nada.
  Future<String?> performOcr(String photoPath) async {
    // En producción:
    // 1. Intentar OCR offline con Tesseract / Google ML Kit
    // 2. Fallback a OCR remoto vía API de Odoo
    // Mientras tanto, retornamos null para forzar ingreso manual.
    return null;
  }

  /// Valida formato de lectura (enteros y decimales).
  static bool validateReading(String text) {
    if (text.trim().isEmpty) return false;
    // Patrón: dígitos con punto decimal opcional
    final pattern = RegExp(r'^\d+\.?\d*$');
    return pattern.hasMatch(text.trim());
  }

  /// Extrae solo dígitos y punto decimal.
  static String sanitizeReading(String? text) {
    if (text == null) return '';
    return text.replaceAll(RegExp(r'[^\d.]'), '');
  }
}