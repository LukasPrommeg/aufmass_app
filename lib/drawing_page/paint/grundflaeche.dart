import 'package:aufmass_app/drawing_page/paint/flaeche.dart';
import 'package:aufmass_app/drawing_page/paint/wall.dart';
import 'package:flutter/material.dart';

class Grundflaeche extends Flaeche {
  String raumName;
  Color color = Colors.black;

  Grundflaeche({
    required this.raumName,
    required List<Wall> walls,
  }) : super(walls: walls);

  void paintGrundflaeche(Canvas canvas, double size) {
    super.paint(canvas, raumName, color, true, size);
  }
}
