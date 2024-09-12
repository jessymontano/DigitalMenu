import 'package:digital_menu/src/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart'; // Asegúrate de que la ruta sea correcta
import 'package:digital_menu/src/widgets/input.dart'; // Asegúrate de que la ruta sea correcta

void main() {
  testWidgets('El widget de registrarse muestra la cantidad correcta de Inputs',
      (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SignUpForm(),
        ),
      ),
    );

    // revisar si existe la cantidad correcta de inputs
    expect(find.byType(Input), findsNWidgets(5));
  });
  testWidgets("El boton de cancelar lleva al formulario de login",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SignUpForm(),
        ),
      ),
    );
    // asegurar que el boton de cancelar sea visible
    await tester.ensureVisible(find.byKey(Key('cancelButton')));
    //hacer tap en el boton para cancelar
    await tester.tap(find.byKey(const Key("cancelButton")));

    //esperar a que el widget termine de cargar
    await tester.pumpAndSettle();
    await tester.pump(new Duration(milliseconds: 6000));

    // revisar si los titulos corresponden al widget de login
    expect(find.text("REGÍSTRATE"), findsNothing);
    expect(find.text("INICIAR SESIÓN"), findsOneWidget);
  });

  testWidgets(
      "Al intentar registrarse con los campos vacios se muestran mensajes de error",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SignUpForm(),
        ),
      ),
    );

    await tester.tap(find.byKey(Key("signupButton")));

    await tester.pumpAndSettle();

    expect(find.text("Ingrese un nombre de usuario"), findsOneWidget);
    expect(find.text("Ingrese un nombre"), findsOneWidget);
    expect(find.text("Ingrese su email"), findsOneWidget);
    expect(find.text("Ingrese una contraseña"), findsOneWidget);
    expect(find.text("Repita su contraseña"), findsOneWidget);
  });

  testWidgets("Al ingresar un email invalido se muestra un mensaje de error",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SignUpForm(),
        ),
      ),
    );
    await tester.enterText(find.byKey(Key("emailInput")), "prueba");
    await tester.tap(find.byKey(Key("signupButton")));

    await tester.pumpAndSettle();
    expect(find.text("Ingrese un email válido"), findsOneWidget);
  });

  testWidgets(
      "Al ingresar contraseñas diferentes se muestra un mensaje de error",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SignUpForm(),
        ),
      ),
    );
    await tester.enterText(find.byKey(Key("passwordInput")), "prueba");
    await tester.enterText(find.byKey(Key("repeatPasswordInput")), "prueba1");
    await tester.tap(find.byKey(Key("signupButton")));

    await tester.pumpAndSettle();
    expect(find.text("Las contraseñas deben ser iguales"), findsAtLeast(1));
  });
}
