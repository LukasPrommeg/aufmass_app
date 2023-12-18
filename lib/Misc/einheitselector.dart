import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';


class EinheitSelector extends StatefulWidget {
  EinheitSelector({super.key});

  final controller = PaintController();

  @override
  State<EinheitSelector> createState() => _EinheitSelectorState();
}

class _EinheitSelectorState extends State<EinheitSelector> {
  final List<ButtonSegment<Einheit>> _segments = [];

  _EinheitSelectorState() {
    for (Einheit einheit in Einheit.values) {
      _segments.add(ButtonSegment<Einheit>(
          value: einheit, label: Text(einheit.name)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Einheit>(
      multiSelectionEnabled: false,
      emptySelectionAllowed: false,
      showSelectedIcon: false,
      segments: _segments,
      selected: {widget.controller.selectedEinheit},
      onSelectionChanged: (newVal) {
        setState(() {
          widget.controller.selectedEinheit = newVal.first;
        });
      },
    );
  }
}
