import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const Button({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            maximumSize: Size(250, 100),
            backgroundColor: const Color.fromARGB(255, 212, 10, 8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text(text));
  }
}
