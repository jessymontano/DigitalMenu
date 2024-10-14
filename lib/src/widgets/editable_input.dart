import 'package:flutter/material.dart';

class EditableInput extends StatefulWidget {
  final TextEditingController controller;

  EditableInput({
    super.key,
    required this.controller,
  });

  @override
  _EditableInputState createState() => _EditableInputState();
}

class _EditableInputState extends State<EditableInput> {
  FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: EditableText(
            onTapOutside: (tapOutside) {
              focusNode.unfocus();
            },
            focusNode: focusNode,
            controller: widget.controller,
            cursorColor: const Color.fromARGB(255, 212, 10, 8),
            backgroundCursorColor: Colors.black,
            style: const TextStyle(color: Colors.black),
          ),
        ));
  }
}
