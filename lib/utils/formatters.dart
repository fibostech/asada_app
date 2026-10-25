import 'dart:convert';
import 'intl/intl.dart' as intl;

/// Formateo de valores para la UI.
class Formatters {
  static final intl.NumberFormat _numberFormat = intl.NumberFormat(
    locale: 'es_CR',
    minimumFractionDigits: 1,
    maximumFractionDigits: 2,
  );

  /// Formatea valor de lectura.
  static String formatReading(double value) {
    return _numberFormat.format(value);
  }

  /// Formatea fecha para la UI.
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Formatea hora.
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  /// Formatea fecha y hora.
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  /// Trunca texto largo.
  static String truncate(String text, int maxLength) {
    if (text == null) return '';
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Formatea progreso como porcentaje.
  static String formatProgress(int completed, int total) {
    if (total == 0) return '0%';
    final percent = (completed / total * 100).toStringAs(places: 1);
    return '$percent%';
  }
}