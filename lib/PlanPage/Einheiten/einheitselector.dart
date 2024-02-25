import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitcontroller.dart';

typedef OnChangeCallback = void Function(Einheit);

//ignore: must_be_immutable
class EinheitSelector extends StatefulWidget {
  EinheitSelector({super.key, this.setGlobal = false, this.onChangeCallback}) {
    selected = controller.selectedEinheit;
  }

  final controller = EinheitController();
  final OnChangeCallback? onChangeCallback;
  final bool setGlobal;
  late Einheit selected;

  @override
  State<EinheitSelector> createState() => _EinheitSelectorState();

  double convertToMM(double value) {
    switch (selected) {
      case Einheit.cm:
        value *= 10;
        break;
      case Einheit.m:
        value *= 1000;
        break;
      default:
        break;
    }
    return value;
  }
}

class _EinheitSelectorState extends State<EinheitSelector> {
  final List<ButtonSegment<Einheit>> _segments = [];

  _EinheitSelectorState() {
    for (Einheit einheit in Einheit.values) {
      _segments.add(ButtonSegment<Einheit>(value: einheit, label: Text(einheit.name)));
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
          if (widget.onChangeCallback != null) {
            widget.onChangeCallback!(widget.selected);
          }
        });
      },
    );
  }
}
