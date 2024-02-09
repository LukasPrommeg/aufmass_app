import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/linie.dart';

class LinePainter extends CustomPainter {
  LinePainter({required Listenable repaint}) : super(repaint: repaint);
  List<Linie> _walls = [];
  final List<Punkt> _ends = [];
  bool isDrawing = false;

  Punkt? selectedCorner;

  void drawWalls(List<Linie> walls) {
    _walls.clear();
    _ends.clear();
    if (walls.isEmpty) {
      return;
    }

    isDrawing = true;
    _walls = walls.toList();
    if (_walls.isNotEmpty) {
      _ends.add(_walls.first.start);
      _ends.add(_walls.last.end);
    }
  }

  bool finishArea() {
    if (_walls.length > 1) {
      _walls.clear();
      isDrawing = false;
      selectedCorner = null;
      return true;
    }
    return false;
  }

  void reset() {
    _walls.clear();
    isDrawing = false;
    selectedCorner = null;
  }

  Punkt? detectClickedCorner(Offset location) {
    for (Punkt corner in _ends) {
      if (corner.contains(location)) {
        return corner;
      }
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_walls.isEmpty) {
      if (selectedCorner != null) {
        selectedCorner!.selected = true;
        selectedCorner!.paint(canvas, Colors.blue, 15);
        selectedCorner!.paintHB(canvas);
        selectedCorner!.selected = false;
        Paint paint = Paint()
          ..color = Colors.blue
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round;

        canvas.drawPoints(PointMode.points, [selectedCorner!.scaled!], paint);
      }
      return;
    }

    for (Linie wall in _walls) {
      wall.paint(canvas, Colors.black, 5);
      wall.paintLaengen(canvas, Colors.black, 20);
    }

    for (Punkt corner in _ends) {
      if (selectedCorner != null && selectedCorner!.point == corner.point) {
        corner.selected = true;
      }
      corner.paintHB(canvas);
      corner.selected = false;
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return false;
  }
}
