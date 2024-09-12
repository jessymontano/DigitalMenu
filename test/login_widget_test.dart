import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_menu/src/pages/login.dart';
import 'package:digital_menu/src/widgets/input.dart';

void main() {
  testWidgets('El Login muestra la cantidad correcta de Inputs',
      (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoginForm(),
        ),
      ),
    );

    // revisar si existe la cantidad correcta de inputs
    expect(find.byType(Input), findsNWidgets(2));

    // revisar si el input para el usuario tiene el texto correcto
    final hintTextFinder = find.widgetWithText(Input, 'Ingrese el usuario');
    final labelTextFinder = find.widgetWithText(Input, 'Usuario');

    expect(hintTextFinder, findsOneWidget);
    expect(labelTextFinder, findsOneWidget);
  });
  testWidgets("El boton de registrate lleva al formulario de registro",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoginForm(),
        ),
      ),
    );
    //hacer tap en el boton para registrarse
    await tester.tap(find.byKey(const Key("signupButton")));

    //esperar a que el widget termine de cargar
    await tester.pumpAndSettle();
    await tester.pump(new Duration(milliseconds: 1000));

    // revisar que el titulo corresponde al widget de signup
    expect(find.text("REGÍSTRATE"), findsOneWidget);
    expect(find.text("INICIAR SESIÓN"), findsNothing);
  });
  testWidgets(
      "El boton de olvide mi contraseña lleva al formulario de recuperar contraseña",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoginForm(),
        ),
      ),
    );
    //hacer tap en el boton de olvide mi contraseña
    await tester.tap(find.byKey(const Key("changePasswordButton")));

    //esperar a que el widget termine de cargar
    await tester.pumpAndSettle();
    await tester.pump(new Duration(milliseconds: 1000));

    // revisar que el titulo corresponde al widget de cambiar contraseña
    expect(find.text("RECUPERAR CONTRASEÑA"), findsOneWidget);
    expect(find.text("INICIAR SESIÓN"), findsNothing);
  });

  testWidgets(
      "Al intentar iniciar sesion con los campos vacios se muestran mensajes de error",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoginForm(),
        ),
      ),
    );

    await tester.tap(find.byKey(Key("loginButton")));
    await tester.pumpAndSettle();

    expect(find.text("Ingrese el usuario"), findsOneWidget);
    expect(find.text("Ingrese su contraseña"), findsOneWidget);
  });
}
