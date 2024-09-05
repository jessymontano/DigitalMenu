import 'package:flutter/material.dart';
import '../widgets/button.dart';
import '../widgets/input.dart';
import 'login.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Formulario en el centro (intentar)
          const Center(
            child: ChangePasswordForm(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/logo.jpg', 
                width: 550, // Ancho
              ),
            ),
          ),
        ],
      ),
    );
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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: RichText(
              text: TextSpan(
                text: 'Introduzca su dirección de correo electrónico a continuación y se le enviará un e-mail con un código de 6 dígitos para restablecer su contraseña.',
                style: DefaultTextStyle.of(context).style,
              ),
            ),
          ),
          Input(
            controller: _emailController,
            hintText: 'ejemplo@gmail.com',
            labelText: 'Email',
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Button(
              onPressed: () {
                //aqui va el codigo para la recuperación
              },
              text: 'Enviar código',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.black)),            
          ),
        ],
      ),
    );
  }
}
