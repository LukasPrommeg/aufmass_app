import 'dart:math';
import 'package:aufmass_app/Misc/hitbox.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/drawing_page/paint/corner.dart';
import 'package:aufmass_app/drawing_page/paint/wall.dart';
import 'package:aufmass_app/Misc/werkstoff.dart';

class Flaeche extends EventArgs {
  List<Wall> _walls = [];
  Wall lastWall = Wall(angle: 0, length: 0);
  Path path = Path();
  Color color = Colors.black;
  String name = "UNNAMED";
  Offset posBeschriftung = const Offset(0, 0);
  double area = 0;
  bool hasBeschriftung;
  Rect size = Rect.zero;

  Werkstoff? werkstoff;

  List<Wall> get walls {
    return _walls;
  }

  Flaeche({
    required List<Wall> walls,
    this.hasBeschriftung = true,
    required double scale,
    required Offset center,
    this.werkstoff=null,
  }) {
    _walls = walls;

    calcSize();
    _calcLastWall();
  }

  ClickAble? findClickedPart(Offset position) {
    if (lastWall.scaledStart != null && lastWall.scaledStart!.contains(position)) {
      return lastWall.scaledStart;
    }
    for (Wall wall in walls) {
      if (wall.scaledStart != null && wall.scaledStart!.contains(position)) {
        return wall.scaledStart;
      }
    }
    if (lastWall.contains(position)) {
      return lastWall;
    }
    for (Wall wall in walls) {
      if (wall.contains(position)) {
        return wall;
      }
    }
    return null;
  }

  void calcSize() {
    size = Rect.zero;
    Offset origin = Offset.zero;
    for (Wall wall in walls) {
      origin += wall.end;
      size = size.expandToInclude(Rect.fromPoints(origin, origin));
    }
  }

  void _calcLastWall() {
    Offset end = Offset.zero;
    for (Wall wall in _walls) {
      end += wall.end;
    }

    double length = sqrt((pow(end.dx, 2) + pow(end.dy, 2)));
    lastWall = Wall(angle: 0, length: length);
    lastWall.scaledStart = walls.last.scaledEnd;
    lastWall.scaledEnd = walls.first.scaledStart;
  }

  void init(double scale, Offset center) {
    Offset origin = Offset.zero - center;
    posBeschriftung = Offset.zero;
    area = 0;

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

    path.lineTo(walls.first.scaledStart!.center.dx, walls.first.scaledStart!.center.dy);

    posBeschriftung = (Offset(posBeschriftung.dx / (walls.length + 1), posBeschriftung.dy / (walls.length + 1)) * scale) - center;
    calcSize();
    _calcLastWall();
  }
}
