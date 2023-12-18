import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/Misc/einheitcontroller.dart';

class EinheitSelector extends StatefulWidget {
  EinheitSelector({super.key, this.setGlobal = false}) {
    selected = controller.selectedEinheit;
  }

  final controller = EinheitController();
  final bool setGlobal;
  late Einheit selected;

  @override
  State<EinheitSelector> createState() => _EinheitSelectorState();
}

class _EinheitSelectorState extends State<EinheitSelector> {
  final List<ButtonSegment<Einheit>> _segments = [];

  _EinheitSelectorState() {
    for (Einheit einheit in Einheit.values) {
      _segments.add(
          ButtonSegment<Einheit>(value: einheit, label: Text(einheit.name)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Einheit>(
      multiSelectionEnabled: false,
      emptySelectionAllowed: false,
      showSelectedIcon: false,
      segments: _segments,
      selected: {widget.selected},
      onSelectionChanged: (newVal) {
        setState(() {
          if (widget.setGlobal) {
            widget.controller.selectedEinheit = newVal.first;
          }
          widget.selected = newVal.first;
        });
      },
    );
  }
}
