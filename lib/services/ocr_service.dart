/// Servicio de OCR para leer medidores desde foto.
/// Simplificado en v1.0: OCR no disponible offline, retorna null
/// para derivar al ingreso manual de la lectura.
class OcrService {
  /// Ejecuta OCR sobre la foto y retorna el texto detectado.
  /// Simplificado: siempre retorna null -> ingreso manual.
  Future<String?> performOcr(String photoPath) async => null;

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