import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const Button({super.key, required this.text, required this.onPressed}); //auxilio

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 212, 10, 8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.fromLTRB(100, 20, 100, 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text(text));
  }
}
