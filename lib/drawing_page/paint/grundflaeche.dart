import 'dart:math';

import 'package:aufmass_app/drawing_page/paint/corner.dart';
import 'package:aufmass_app/drawing_page/paint/flaeche.dart';
import 'package:aufmass_app/drawing_page/paint/wall.dart';
import 'package:flutter/material.dart';

class Grundflaeche extends Flaeche {
  String raumName;
  Color color = Colors.black;
  bool hasBeschriftung;
  bool hasLaengen;
  double drawSize;
  double textSize;
  double laengenSize;

  Grundflaeche({
    required this.raumName,
    required List<Wall> walls,
    this.hasBeschriftung = true,
    this.hasLaengen = true,
    this.drawSize = 5,
    this.textSize = 15,
    this.laengenSize = 15,
  }) : super(walls: walls);

  void paintGrundflaeche(Canvas canvas) {
    super.paint(canvas, color, drawSize);
    if (hasBeschriftung) {
      super.paintBeschriftung(canvas, color, raumName, textSize);
    }
    if (hasLaengen) {
      super.paintLaengen(canvas, color, laengenSize);
    }
  }

  double findMaxLength(Corner startingPoint, double angle) {
    //TODO: async
    double stepLength = 0.001;

    double length = 0;
    Offset einheitsVektor = Offset.fromDirection((angle - 90) * pi / 180, stepLength);
    Offset origin = startingPoint.point;

    do {
      origin += einheitsVektor;
      length += stepLength;
    } while (unscaledPath.contains(origin));

    return double.parse(length.toStringAsFixed(2));
  }
}
