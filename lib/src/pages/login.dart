import 'package:digital_menu/src/pages/signup.dart';
import 'package:digital_menu/src/pages/home.dart';
import 'package:digital_menu/src/pages/password_change.dart';
import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import '../widgets/button.dart';
import '../widgets/input.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
final logo = Image.asset('logo.jpg');

Future<void> storeUser(Map<String, dynamic> user) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', user['nombre_usuario']);
  await prefs.setString('name', user['nombre']);
  await prefs.setString('email', user['correo']);
  await prefs.setString('userRole', user["rol"]);
}

class Login extends StatelessWidget {
  final String? successMessage;
  const Login({super.key, this.successMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
              children: [LoginForm(), logo],
            );
          },
        ),
      ),
    );
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
          padding: const EdgeInsets.fromLTRB(100, 0, 30, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'INICIAR SESIÓN',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                labelText: 'Contraseña',
                obscureText: true,
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
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
                      activeColor: Colors.red,
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChangePassword()));
                      },
                      child: const Text('Olvide mi contraseña.',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Button(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final user = await supabase
                          .from('usuarios')
                          .select()
                          .eq('nombre_usuario', _usernameController.text)
                          .maybeSingle();
                      if (user == null) {
                        setState(() {
                          _errorMessage = 'El ususario no existe.';
                        });
                      } else {
                        final password = user['contrasena'] as String;
                        if (password == _passwordController.text) {
                          storeUser(user);
                          await supabase
                              .from("usuarios")
                              .update({'estado': 'activo'}).eq(
                                  'nombre_usuario', _usernameController);
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
                      child: const Text('Registrate',
                          style: TextStyle(color: Colors.red)))
                ],
              )
            ],
          ),
        ));
  }
}
