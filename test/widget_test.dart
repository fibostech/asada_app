import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asada_app/main.dart';

void main() {
  testWidgets('ASADA App — smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AsadaApp());
    await tester.pump();

    // La app debe mostrar el título
    expect(find.text('ASADA App'), findsOneWidget);

    // Debe mostrar pantalla de login (sin autenticar)
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('INGRESAR'), findsOneWidget);
  });
}