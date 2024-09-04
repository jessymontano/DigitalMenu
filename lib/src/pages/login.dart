import 'package:flutter/material.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: Scaffold(
            body: Row(
      children: [LoginForm()],
    )));
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'INICIAR SESIÓN',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Input(hintText: 'Ingrese el usuario', labelText: 'Usuario'),
          Input(hintText: 'Ingrese la contraseña.', labelText: 'Contraseña'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 200,
                child: CheckboxListTile(
                  value: _rememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      _rememberMe = value!;
                    });
                  },
                  title: const Text('Recuérdame'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              TextButton(
                  onPressed: () {}, child: Text('Olvide mi contraseña.')),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Button(
              onPressed: () {},
              text: 'Iniciar Sesión',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('¿No tienes una cuenta?'),
              TextButton(onPressed: () {}, child: Text('Registrate'))
            ],
          )
        ],
      ),
    );
  }
}
