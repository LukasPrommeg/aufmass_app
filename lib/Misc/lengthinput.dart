import 'package:flutter/material.dart';

//ignore: must_be_immutable
class LengthInput extends StatefulWidget {
  LengthInput({
    super.key,
    required this.hintText,
    required this.drawingGrundflaeche,
    this.maxText = "Maximal möglich",
    this.btnText = "max.",
    this.useMaxValue = false,
  });

  final String hintText;
  final String maxText;
  final String btnText;
  double value = 0;
  late bool useMaxValue;
  bool drawingGrundflaeche;

  @override
  State<LengthInput> createState() => _LengthInputState();
}

class _LengthInputState extends State<LengthInput> {
  final TextEditingController _textFieldController = TextEditingController();
  late List<bool> selection;
  late TextField wallLength;

  @override
  void initState() {
    super.initState();

    selection = [widget.useMaxValue];

    wallLength = TextField(
      controller: _textFieldController,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(hintText: widget.hintText),
      enabled: !widget.useMaxValue,
      onChanged: (value) => submitValue(value),
    );
  }

  void submitValue(String string) {
    try {
      double value = double.parse(string);
      setState(() {
        widget.value = value;
      });
    } catch (e) {
      setState(() {
        widget.value = 0;
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
              widget.useMaxValue = selection[index];
              if (selection[index]) {
                wallLength = TextField(
                  controller: _textFieldController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  enabled: !widget.useMaxValue,
                  decoration: InputDecoration(hintText: widget.maxText),
                  onChanged: (value) => submitValue(value),
                );
                _textFieldController.text = "";
                widget.value = 0;
              } else {
                wallLength = TextField(
                  controller: _textFieldController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  enabled: !widget.useMaxValue,
                  decoration: InputDecoration(hintText: widget.hintText),
                  onChanged: (value) => submitValue(value),
                );
              }
            });
          },
          children: [Text(widget.btnText)],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: maxPossible,
    );
  }
}
