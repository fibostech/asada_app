import 'package:flutter_test/flutter_test.dart';

import 'package:asada_app/services/ocr_service.dart';
import 'package:asada_app/utils/validators.dart';
import 'package:asada_app/utils/formatters.dart';

void main() {
  test('OcrService: sanitize reading removes non-digits', () {
    final sanitized = OcrService.sanitizeReading('12,345.67 abc');
    expect(sanitized, equals('12345.67'));
  });

  test('OcrService: sanitize reading null returns empty', () {
    expect(OcrService.sanitizeReading(null), equals(''));
  });

  test('OcrService: validateReading correct formats', () {
    expect(OcrService.validateReading('12345'), isTrue);
    expect(OcrService.validateReading('12345.6'), isTrue);
    expect(OcrService.validateReading('0.1'), isTrue);
  });

  test('OcrService: validateReading incorrect formats', () {
    expect(OcrService.validateReading(''), isFalse);
    expect(OcrService.validateReading('abc'), isFalse);
    expect(OcrService.validateReading('12.34.56'), isFalse);
    expect(OcrService.validateReading('-5'), isFalse);
  });

  test('Validators: email validation', () {
    expect(Validators.isValidEmail('user@example.com'), isTrue);
    expect(Validators.isValidEmail('user@example.co.cr'), isTrue);
    expect(Validators.isValidEmail('not-an-email'), isFalse);
    expect(Validators.isValidEmail(''), isFalse);
    expect(Validators.isValidEmail(null), isFalse);
  });

  test('Validators: server URL validation', () {
    expect(Validators.isValidServerUrl('https://odoo.example.com'), isTrue);
    expect(Validators.isValidServerUrl('http://localhost:8069'), isTrue);
    expect(Validators.isValidServerUrl('not-a-url'), isFalse);
    expect(Validators.isValidServerUrl(''), isFalse);
  });

  test('Validators: reading value', () {
    expect(Validators.isValidReadingValue('12345'), isTrue);
    expect(Validators.isValidReadingValue('12345.6'), isTrue);
    expect(Validators.isValidReadingValue('-1'), isFalse);
    expect(Validators.isValidReadingValue('abc'), isFalse);
  });

  test('Formatters: format date', () {
    final date = DateTime(2026, 10, 25);
    expect(Formatters.formatDate(date), equals('25/10/2026'));
  });

  test('Formatters: truncate', () {
    expect(Formatters.truncate('Hola mundo', 4), equals('Hola...'));
    expect(Formatters.truncate('Hola', 10), equals('Hola'));
  });

  test('Formatters: format progress', () {
    expect(Formatters.formatProgress(3, 10), equals('30.0%'));
    expect(Formatters.formatProgress(0, 10), equals('0.0%'));
    expect(Formatters.formatProgress(0, 0), equals('0%'));
  });
}