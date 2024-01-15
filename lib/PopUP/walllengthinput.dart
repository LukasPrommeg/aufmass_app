import 'package:flutter/material.dart';

//ignore: must_be_immutable
class WallInput extends StatefulWidget {
  WallInput({super.key, required this.drawingGrundflaeche});

  double length = 0;
  bool useMaxLength = false;
  bool drawingGrundflaeche;

  @override
  State<WallInput> createState() => _WallInputState();
}

class _WallInputState extends State<WallInput> {
  final TextEditingController _textFieldController = TextEditingController();
  List<bool> selection = [false];
  late TextField wallLength;

  _WallInputState() {
    wallLength = TextField(
      controller: _textFieldController,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(hintText: "Länge der Wand"),
      onChanged: (value) => submitValue(value),
    );
  }

  void submitValue(String string) {
    try {
      double value = double.parse(string);
      setState(() {
        widget.length = value;
      });
    } catch (e) {
      setState(() {
        widget.length = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> maxPossible = [
      Expanded(
        child: wallLength,
      ),
    ];
    if (!widget.drawingGrundflaeche) {
      maxPossible.add(
        const SizedBox(
          width: 10,
        ),
      );
      maxPossible.add(
        ToggleButtons(
          isSelected: selection,
          onPressed: (index) {
            setState(() {
              selection[index] = !selection[index];
              widget.useMaxLength = selection[index];
              if (selection[index]) {
                wallLength = TextField(
                  controller: _textFieldController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  enabled: false,
                  decoration: const InputDecoration(hintText: "Maximale mögliche Länge"),
                  onChanged: (value) => submitValue(value),
                );
                _textFieldController.text = "";
                widget.length = 0;
              } else {
                wallLength = TextField(
                  controller: _textFieldController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  enabled: true,
                  decoration: const InputDecoration(hintText: "Länge der Wand"),
                  onChanged: (value) => submitValue(value),
                );
              }
            });
          },
          children: const [Text("max.")],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: maxPossible,
    );
  }
}
