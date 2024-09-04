import 'package:digital_menu/src/pages/signup.dart';
import 'package:digital_menu/src/pages/home.dart';
import 'package:digital_menu/src/pages/password_change.dart';
import 'package:flutter/material.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class Login extends StatelessWidget {
  final String? successMessage;
  const Login({super.key, this.successMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(
      body: Builder(
        builder: (context) {
          if (successMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(successMessage!)),
              );
            });
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [LoginForm(), Image.asset('logo.jpg')],
          );
        },
      ),
    ));
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.fromLTRB(100, 0, 30, 0),
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
              Input(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su usuario';
                    }
                    return null;
                  },
                  controller: _usernameController,
                  hintText: 'Ingrese el usuario',
                  labelText: 'Usuario'),
              Input(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su contraseña';
                    }
                    return null;
                  },
                  controller: _passwordController,
                  hintText: 'Ingrese la contraseña.',
                  labelText: 'Contraseña'),
              if (_errorMessage.isNotEmpty)
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    )),
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
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChangePassword()));
                      },
                      child: const Text('Olvide mi contraseña.')),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Button(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final user = await db
                          .collection('usuarios')
                          .where('username',
                              isEqualTo: _usernameController.text)
                          .get();
                      if (user.docs.isEmpty) {
                        setState(() {
                          _errorMessage = 'El ususario no existe.';
                        });
                      } else {
                        final doc = user.docs.first;
                        if (doc['password'] == _passwordController.text) {
                          setState(() {
                            _errorMessage = '';
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Home()));
                          });
                        } else {
                          setState(() {
                            _errorMessage = 'Contraseña incorrecta';
                          });
                        }
                      }
                    }
                  },
                  text: 'Iniciar Sesión',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('¿No tienes una cuenta?'),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp()));
                      },
                      child: const Text('Registrate'))
                ],
              )
            ],
          ),
        ));
  }
}
