import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final Size size;
  final VoidCallback onPressed;

  const Button(
      {super.key,
      required this.text,
      required this.size,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            maximumSize: size,
            backgroundColor: const Color.fromARGB(255, 212, 10, 8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text(text));
  }
}
