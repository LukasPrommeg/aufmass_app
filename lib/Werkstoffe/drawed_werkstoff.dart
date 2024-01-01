import 'package:aufmass_app/Misc/clickable.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';

class DrawedWerkstoff extends EventArgs {
  final ClickAble clickAble;
  final Werkstoff werkstoff;
  final bool beschriftung;

  DrawedWerkstoff({required this.clickAble, required this.werkstoff, required this.beschriftung});

  void paint(Canvas canvas, double size) {
    clickAble.paint(canvas, werkstoff.name, werkstoff.color, beschriftung, size);
  }

  bool contains(Offset position) {
    return clickAble.contains(position);
  }
}
