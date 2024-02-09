import 'package:flutter/material.dart';

class DeleteDialog extends StatefulWidget {
  final String title;

  const DeleteDialog({required this.title, super.key});

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
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
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () {
            delete = true;
            Navigator.of(context).pop(delete); // Close the dialog and pass the result (input string)
          },
          child: const Text('Weiter'),
        ),
      ],
    );
  }
}
