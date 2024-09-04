import 'package:digital_menu/src/pages/login.dart';
import 'package:digital_menu/src/pages/signup.dart';
import 'package:flutter/material.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: Scaffold(
      body: Center(
        child: ChangePasswordForm(),
      ),
    ));
  }
}

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

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
              'RECUPERAR CONTRASEÑA',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: RichText(
                text: TextSpan(
                    text:
                        'Introduzca su dirección de correo eléctronico a continuación y se le enviará un e-mail con un código de 6 dígitos para reestablecer su contraseña.')),
          ),
          Input(
            controller: _emailController,
            hintText: 'ejemplo@gmail.com',
            labelText: 'Email',
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Button(
              onPressed: () {},
              text: 'Enviar código',
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              },
              child: const Text('Cancelar'))
        ],
      ),
    );
  }
}
