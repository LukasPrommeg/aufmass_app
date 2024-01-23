import 'package:aufmass_app/2D_Objects/clickable.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';

class DrawedWerkstoff extends EventArgs {
  final ClickAble clickAble;
  Werkstoff werkstoff;
  bool hasBeschriftung;
  bool hasLaengen;
  double drawSize;
  double textSize;
  double laengenSize;

  DrawedWerkstoff({
    required this.clickAble,
    required this.werkstoff,
    this.hasBeschriftung = true,
    this.hasLaengen = false,
    this.drawSize = 5,
    this.textSize = 15,
    this.laengenSize = 15,
  });

  void paint(Canvas canvas) {
    clickAble.paint(canvas, werkstoff.color, drawSize);
    if (hasBeschriftung) {
      clickAble.paintBeschriftung(canvas, werkstoff.color, werkstoff.name, textSize);
    }
    if (hasLaengen) {
      clickAble.paintLaengen(canvas, werkstoff.color, laengenSize);
    }
  }

  bool contains(Offset position) {
    return clickAble.contains(position);
  }
}
