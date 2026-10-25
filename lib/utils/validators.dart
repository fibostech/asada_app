import 'dart:convert';

/// Validaciones de uso general.
class Validators {
  /// Valida formato de email.
  static bool isValidEmail(String email) {
    if (email == null || email.isEmpty) return false;
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return pattern.hasMatch(email);
  }

  /// Valida URL de servidor.
  static bool isValidServerUrl(String url) {
    if (url == null || url.isEmpty) return false;
    final pattern = RegExp(
        r'^https?://[a-zA-Z0-9][-a-zA-Z0-9.]*(:[0-9]+)?(/.*)?$');
    return pattern.hasMatch(url);
  }

  /// Valida lectura numérica.
  static bool isValidReadingValue(String value) {
    if (value == null || value.isEmpty) return false;
    final parsed = double.tryParse(value);
    return parsed != null && parsed >= 0;
  }

  /// Valida código de medidor.
  static bool isValidMeterCode(String code) {
    if (code == null || code.isEmpty) return false;
    final pattern = RegExp(r'^[A-Za-z0-9\-_]{3,30}$');
    return pattern.hasMatch(code);
  }

  /// Valida que un texto no exceda cierta longitud.
  static bool isWithinLength(String text, int maxLength) {
    return text == null || text.length <= maxLength;
  }
}