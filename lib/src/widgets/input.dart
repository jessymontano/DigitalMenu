import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final bool obscureText; // Agregamos el parámetro 'obscureText'

  Input({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.controller,
    this.validator,
    this.obscureText = false, // Por defecto es falso, pero puede activarse
  });

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: widget.controller,
            cursorColor: const Color.fromARGB(255, 212, 10, 8),
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 212, 10, 8)),
                  borderRadius: BorderRadius.circular(10.0)),
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.black),
            ),
            obscureText: widget.obscureText,
            validator: widget.validator,
            style: const TextStyle(color: Colors.black),
          ),
        ));
  }
}
