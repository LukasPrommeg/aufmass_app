import 'package:flutter/material.dart';

class TextInputDialog extends StatefulWidget {
  final String title;
  final String placeholder;

  const TextInputDialog(this.title, this.placeholder, {super.key});

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _textEditingController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: widget.placeholder,
        ),
        onSubmitted: (String result) {
          Navigator.of(context).pop(result); // Close the dialog and pass the result (input string)
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog without returning any value
          },
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () {
            String result = _textEditingController.text;
            Navigator.of(context).pop(result); // Close the dialog and pass the result (input string)
          },
          child: const Text('Weiter'),
        ),
      ],
    );
  }
}
