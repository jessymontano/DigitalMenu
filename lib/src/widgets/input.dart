import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  Input({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.controller,
    this.validator,
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
            cursorColor: Color.fromARGB(255, 212, 10, 8),
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(color: Colors.black), 
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 212, 10, 8)),
                  borderRadius: BorderRadius.circular(10.0)),
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.black),
            ),
            validator: widget.validator,
            style: TextStyle(color: Colors.black),
          ),
        ));
  }
}
