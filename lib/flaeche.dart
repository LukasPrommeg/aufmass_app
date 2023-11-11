import 'package:flutter/material.dart';

class Flaeche {
  Flaeche({
    required this.area,
  }) {
    path.moveTo(area.first.dx, area.first.dy);
    area.removeAt(0);
    for (Offset point in area) {
      path.lineTo(point.dx, point.dy);
      center += point;
    }
    center = Offset(center.dx / area.length, center.dy / area.length);
  }

  final List<Offset> area;
  Path path = Path();
  Color color = Colors.black;
  String name = "";
  Offset center = const Offset(0, 0);

  Map toJson() => {
        'area': area,
        'path': path,
        'color': color,
        'name': name,
      };
}
