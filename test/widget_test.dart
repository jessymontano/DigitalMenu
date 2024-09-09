import 'package:digital_menu/src/pages/login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('El boton de registrarse lleva al formulario para registrarse',
      (WidgetTester tester) async {
    // inicializar widget de LoginForm
    await tester.pumpWidget(const LoginForm());

    // usar key para buscar el boton de registrarse
    expect(find.byKey(const Key("signupButton")), findsOneWidget);
  });
}
