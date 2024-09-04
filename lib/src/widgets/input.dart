import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  final String hintText;
  final String labelText;
  final FormFieldValidator<String>? validator;

  Input({required this.hintText, required this.labelText, this.validator});

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 400,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: widget.labelText,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 212, 10, 8)),
                  borderRadius: BorderRadius.circular(10.0)),
              hintText: widget.hintText,
            ),
            validator: widget.validator,
          ),
        ));
  }
}
