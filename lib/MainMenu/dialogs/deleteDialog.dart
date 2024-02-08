import 'dart:ffi';

import 'package:flutter/material.dart';

class DeleteDialog extends StatefulWidget {
  String title = "";

  DeleteDialog(this.title);

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  bool delete = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(delete); // Close the dialog without returning any value
          },
          child: Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () {
            delete = true;
            Navigator.of(context).pop(delete); // Close the dialog and pass the result (input string)
          },
          child: Text('Weiter'),
        ),
      ],
    );
  }
}