import 'package:flutter/material.dart';

class TextInputDialog extends StatefulWidget {
  String title = "";
  String placeholder = "";

  TextInputDialog(this.title, this.placeholder);

  @override
  _TextInputDialogState createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _textEditingController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
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
          child: Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () {
            String result = _textEditingController.text;
            Navigator.of(context).pop(result); // Close the dialog and pass the result (input string)
          },
          child: Text('Weiter'),
        ),
      ],
    );
  }
}