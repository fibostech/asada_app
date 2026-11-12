import 'package:flutter_test/flutter_test.dart';

import 'package:asada_app/main.dart';

void main() {
  testWidgets('ASADA App — smoke test: muestra pantalla de pairing inicial',
      (WidgetTester tester) async {
    await tester.pumpWidget(AsadaApp());
    await tester.pump();

    // La app debe mostrar el título
    expect(find.text('ASADA App'), findsOneWidget);

    // Debe mostrar pantalla de pairing (sin config guardada)
    expect(find.text('Configuración inicial'), findsOneWidget);
    expect(find.text('Escanear QR'), findsOneWidget);
    expect(find.text('Ingresar código'), findsOneWidget);
    expect(find.text('Configurar manualmente'), findsOneWidget);
  });
}
