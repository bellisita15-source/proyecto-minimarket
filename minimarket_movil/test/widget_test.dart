import 'package:flutter_test/flutter_test.dart';
import 'package:minimarket_movil/main.dart';

void main() {
  testWidgets('Carga inicial de Minimarket Flash App', (WidgetTester tester) async {
    // Renderizar la aplicación principal de Minimarket
    await tester.pumpWidget(const MinimarketFlashApp());

    // Verificar que el título del Login o formulario esté presente
    expect(find.text('Iniciar Sesión en el Sistema'), findsOneWidget);
    expect(find.text('Completar Registro'), findsNothing);
  });
}