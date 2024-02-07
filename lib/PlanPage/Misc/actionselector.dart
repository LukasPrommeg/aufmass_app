import 'package:flutter/material.dart';

//ignore: must_be_immutable
class ActionSelector extends StatefulWidget {
  ActionSelector({super.key});

  String selected = "";

  @override
  State<ActionSelector> createState() => _ActionSelectorState();
}

class _ActionSelectorState extends State<ActionSelector> {
  List<ButtonSegment<String>> segments = [
    const ButtonSegment(
      value: "Werkstoff",
      label: Text("Werkstoff"),
    ),
    const ButtonSegment(
      value: "Ausnahme",
      label: Text("Ausnahme"),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      multiSelectionEnabled: false,
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      segments: segments,
      selected: {widget.selected},
      style: const ButtonStyle(shape: MaterialStatePropertyAll(ContinuousRectangleBorder())),
      onSelectionChanged: (newVal) {
        setState(() {
          if (newVal.isEmpty) {
            widget.selected = "";
          } else {
            widget.selected = newVal.first;
          }
        });
      },
    );
  }
}
