import 'dart:math';
import 'package:aufmass_app/Misc/clickable.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/drawing_page/paint/wall.dart';

class Flaeche extends ClickAble {
  List<Wall> _walls = [];
  late Wall lastWall;
  Path path = Path();
  Color color = Colors.black;
  String name = "UNNAMED";
  double area = 0;
  bool hasBeschriftung;
  Rect size = Rect.zero;

  List<Wall> get walls {
    return _walls;
  }

  Flaeche({
    required List<Wall> walls,
    this.hasBeschriftung = true,
  }) : super(hbSize: 0) {
    _walls = walls;

    calcSize();
    _calcLastWall();
  }

  ClickAble? findClickedPart(Offset position) {
    if (lastWall.start.scaled != null && lastWall.start.contains(position)) {
      return lastWall.start;
    }
    for (Wall wall in walls) {
      if (wall.start.scaled != null && wall.start.contains(position)) {
        return wall.start;
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
    for (Wall wall in walls) {
      size = size.expandToInclude(Rect.fromPoints(wall.end.point, wall.end.point));
    }
  }

  void _calcLastWall() {
    double length = sqrt((pow(_walls.last.end.point.dx - _walls.first.start.point.dx, 2) + pow(_walls.last.end.point.dy - _walls.first.start.point.dy, 2))).abs();
    lastWall = Wall.fromStart(angle: 0, length: length, start: _walls.last.end);
    lastWall.start.scaled = walls.last.end.scaled;
    lastWall.end.scaled = walls.first.start.scaled;
  }

  @override
  void initScale(double scale, Offset center) {
    posBeschriftung = Offset.zero;
    area = 0;

    path = Path();
    path.moveTo(-center.dx, -center.dy);

    for (int i = 0; i < walls.length; i++) {
      if (i > 0) {
        area += walls[i - 1].end.point.dx * (walls[i].end.point).dy;
        area -= walls[i - 1].end.point.dy * (walls[i].end.point).dx;
      }
      posBeschriftung += walls[i].end.point;
      walls[i].initScale(scale, center);
      path.lineTo(walls[i].end.scaled!.dx, walls[i].end.scaled!.dy);
    }
    area = area.abs() / 2;

    path.lineTo(walls.first.start.scaled!.dx, walls.first.start.scaled!.dy);

    posBeschriftung = (Offset(posBeschriftung.dx / (walls.length + 1), posBeschriftung.dy / (walls.length + 1)) * scale) - center;
    calcSize();
    _calcLastWall();
  }

  @override
  void calcHitbox() {
    hitbox = path;
  }

  @override
  void paint(Canvas canvas, String name, Color color, bool beschriftung, double size) {
    // TODO: implement paint
  }
}
