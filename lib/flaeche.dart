import 'dart:math';

import 'package:flutter/material.dart';

class Flaeche {
  Flaeche({
    required this.corners,
    //this.hasBeschriftung
  }) {
    for (int i = 1; i < corners.length; i++) {
      area += corners[i - 1].dx * corners[i].dy;
      area -= corners[i - 1].dy * corners[i].dx;

      num diffx = corners[i].dx - corners[i - 1].dx;
      num diffy = corners[i].dy - corners[i - 1].dy;
      double length = sqrt((diffx * diffx) + (diffy * diffy));
      lengths.add(length);
    }
    area /= 2;

    path.moveTo(corners.first.dx, corners.first.dy);
    corners.removeAt(0);
    for (Offset point in corners) {
      path.lineTo(point.dx, point.dy);
      center += point;
    }
    center = Offset(center.dx / corners.length, center.dy / corners.length);
  }

  final List<Offset> corners;
  Path path = Path();
  Color color = Colors.black;
  String name = "unnamed";
  Offset center = const Offset(0, 0);
  double area = 0;
  List<double> lengths = [];
  //bool hasBeschriftung = true;

  Map toJson() => {
        'area': corners,
        'path': path,
        'color': color,
        'name': name,
      };
}
