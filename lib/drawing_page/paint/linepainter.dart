import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aufmass_app/drawing_page/paint/corner.dart';
import 'package:aufmass_app/drawing_page/paint/wall.dart';

class LinePainter extends CustomPainter {
  LinePainter({required Listenable repaint}) : super(repaint: repaint);
  List<Wall> _walls = [];
  final List<Corner> _ends = [];
  bool isDrawing = false;

  Corner? selectedCorner;
  Corner? startingPoint;

  void drawWalls(List<Wall> walls) {
    if (walls.isEmpty) {
      return;
    }
    _walls.clear();
    _ends.clear();
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

  Corner? detectClickedCorner(Offset location) {
    for (Corner corner in _ends) {
      if (corner.contains(location)) {
        return corner;
      }
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (startingPoint != null) {
      startingPoint!.selected = true;
      startingPoint!.paint(canvas, "", Colors.red, false, 10);
      startingPoint!.paintHB(canvas);
      startingPoint!.selected = false;
      Paint paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawPoints(PointMode.points, [startingPoint!.scaled!], paint);
    }

    if (_walls.isEmpty) {
      return;
    }

    for (Wall wall in _walls) {
      wall.paint(canvas, "", Colors.black, true, 10);
    }

    for (Corner corner in _ends) {
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
