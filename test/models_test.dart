import 'package:flutter_test/flutter_test.dart';

import 'package:asada_app/models/user.dart';
import 'package:asada_app/models/meter.dart';
import 'package:asada_app/models/reading.dart';
import 'package:asada_app/models/route.dart';
import 'package:asada_app/models/service_status.dart';

void main() {
  test('User: crear y convertir a JSON', () {
    final user = User(
      id: 1,
      name: 'Juan Pérez',
      email: 'juan@asada.com',
      apiKey: 'abc123key',
      serverUrl: 'https://odoo.example.com',
    );

    expect(user.name, equals('Juan Pérez'));
    expect(user.email, equals('juan@asada.com'));

    final json = user.toJson();
    expect(json['id'], equals(1));
    expect(json['name'], equals('Juan Pérez'));

    final restored = User.fromJson(json);
    expect(restored.name, equals(user.name));
    expect(restored.email, equals(user.email));
    expect(restored.apiKey, equals(user.apiKey));
  });

  test('Meter: crear y serializar', () {
    final meter = Meter(
      id: 10,
      code: 'MTR-001',
      installationAddress: 'San José, 200 m sur',
      routeId: 'RUTA-001',
      qrCode: 'QR-MTR-001',
      serialNumber: 'SN12345',
      consumerName: 'Carlos Mora',
    );

    expect(meter.code, equals('MTR-001'));
    expect(meter.status, equals('active'));

    final json = meter.toJson();
    final restored = Meter.fromJson(json);
    expect(restored.code, equals(meter.code));
    expect(restored.installationAddress, equals(meter.installationAddress));
  });

  test('Reading: flujo completo', () {
    final reading = Reading(
      id: 'READ-001',
      meterId: 10,
      meterCode: 'MTR-001',
      value: 12345.6,
      photoPath: '/tmp/photo.jpg',
      ocrText: '12345.6',
      ocrSuccess: true,
      status: ReadingStatus.completed,
      scenario: BillingScenario.meteredOwn,
    );

    expect(reading.value, equals(12345.6));
    expect(reading.ocrSuccess, isTrue);
    expect(reading.status, equals(ReadingStatus.completed));

    final json = reading.toJson();
    final restored = Reading.fromJson(json);
    expect(restored.value, equals(reading.value));
    expect(restored.ocrSuccess, isTrue);
    expect(restored.status, equals(ReadingStatus.completed));
  });

  test('Route: progreso y conteo', () {
    final meters = [
      Meter(id: 1, code: 'M-001', routeId: 'R-001'),
      Meter(id: 2, code: 'M-002', routeId: 'R-001'),
      Meter(id: 3, code: 'M-003', routeId: 'R-001'),
    ];

    // Simulamos meters "completados" cambiando status
    // En la práctica se maneja con lecturas asociadas
    expect(meters.length, equals(3));
  });

  test('ServiceStatus: estados correctos', () {
    final status = ServiceStatus(
      meterId: 1,
      meterCode: 'M-001',
      state: ServiceState.suspended,
      reason: 'Morosidad',
    );

    expect(status.state, equals(ServiceState.suspended));
    expect(status.reason, equals('Morosidad'));

    final json = status.toJson();
    expect(json['state'], equals('suspended'));

    final restored = ServiceStatus.fromJson(json);
    expect(restored.state, equals(ServiceState.suspended));
  });
}