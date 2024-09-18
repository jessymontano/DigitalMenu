import 'package:flutter/material.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [const SignUpForm(), Image.asset('logo.jpg')],
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
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
                  'REGÍSTRATE',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Input(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese un nombre de usuario';
                    }
                    return null;
                  },
                  controller: _usernameController,
                  hintText: 'Ingrese el nombre de usuario',
                  labelText: 'Nombre de usuario'),
              Input(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su nombre completo';
                    }
                    return null;
                  },
                  controller: _nameController,
                  hintText: 'Ingrese su nombre completo',
                  labelText: 'Nombre completo'),
              Input(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Ingrese un email válido';
                    }
                    return null;
                  },
                  controller: _emailController,
                  hintText: 'ejemplo@gmail.com',
                  labelText: 'Correo electrónico'),
              Input(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese una contraseña';
                  } else if (value != _repeatPasswordController.text) {
                    return 'Las contraseñas deben ser iguales';
                  }
                  return null;
                },
                controller: _passwordController,
                hintText: 'Ingrese su contraseña',
                labelText: 'Contraseña',
                obscureText: true,
              ),
              Input(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Repita su contraseña';
                  } else if (value != _passwordController.text) {
                    return 'Las contraseñas deben ser iguales';
                  }
                  return null;
                },
                controller: _repeatPasswordController,
                hintText: 'Vuelva a ingresar su contraseña',
                labelText: 'Confirmar contraseña',
                obscureText: true,
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    )),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Button(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final checkEmail = await supabase
                          .from('usuarios')
                          .select()
                          .eq('correo', _emailController.text)
                          .maybeSingle();
                      final checkUsername = await supabase
                          .from("usuarios")
                          .select()
                          .eq("nombre_usuario", _usernameController.text)
                          .maybeSingle();
                      if (checkEmail != null) {
                        setState(() {
                          _errorMessage =
                              'Ya existe un usuario asociado a ese email.';
                        });
                      } else if (checkUsername != null) {
                        setState(() {
                          _errorMessage = 'El nombre de usuario ya existe.';
                        });
                      } else {
                        final user = <String, dynamic>{
                          'nombre_usuario': _usernameController.text,
                          'nombre': _nameController.text,
                          'correo': _emailController.text,
                          'contrasena': _passwordController.text,
                        };
                        await supabase.from('usuarios').insert(user);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login(
                                      successMessage:
                                          'Usuario registrado correctamente.',
                                    )));
                      }
                    }
                  },
                  text: 'Crear Cuenta',
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.black),
                  ))
            ],
          ),
        ));
  }
}
