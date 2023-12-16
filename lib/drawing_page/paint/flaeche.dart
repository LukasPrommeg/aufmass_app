import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/corner.dart';
import 'package:flutter_test_diplom/drawing_page/paint/wall.dart';

class Flaeche {
  List<Wall> walls;
  Path path = Path();
  Color color = Colors.black;
  String name = "UNNAMED";
  Offset posBeschriftung = const Offset(0, 0);
  double area = 0;
  bool hasBeschriftung;

  Flaeche({
    required this.walls,
    this.hasBeschriftung = true,
    required double scale,
    required Offset center,
  });

  void init(double scale, Offset center) {
    Offset origin = Offset.zero - center;
    posBeschriftung = Offset.zero;

    path = Path();
    path.moveTo(origin.dx, origin.dy);

    Offset end = walls.first.end;

    for (int i = 0; i < walls.length; i++) {
      if (i > 0) {
        area += end.dx * (end + walls[i].end).dy;
        area -= end.dy * (end + walls[i].end).dx;

        posBeschriftung += end;
        end += walls[i].end;
        if (i == walls.length - 1) {
          posBeschriftung += end;
        }
      }
      walls[i].scaledStart = Corner(center: origin);
      origin += (walls[i].end * scale);
      walls[i].scaledEnd = Corner(center: origin);
      path.lineTo(walls[i].scaledEnd!.center.dx, walls[i].scaledEnd!.center.dy);
    }
    area = area.abs() / 2;
    path.lineTo(
        walls.first.scaledStart!.center.dx, walls.first.scaledStart!.center.dy);

    posBeschriftung = (Offset(posBeschriftung.dx / (walls.length + 1),
                posBeschriftung.dy / (walls.length + 1)) *
            scale) -
        center;
  }
}
