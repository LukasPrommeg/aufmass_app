import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aufmass_app/drawing_page/paint/corner.dart';
import 'package:aufmass_app/drawing_page/paint/wall.dart';

class LinePainter extends CustomPainter {
  LinePainter({required Listenable repaint}) : super(repaint: repaint);

  final List<Offset> _points = [];
  final List<Corner> _ends = [];
  bool isDrawing = false;

  Corner? selectedCorner;

  void drawWalls(List<Wall> walls) {
    _points.clear();
    for (Wall wall in walls) {
      addWall(wall);
    }
  }

  void addWall(Wall wall, {bool addInfront = false}) {
    if (_points.isEmpty) {
      isDrawing = true;
      _ends.clear();
      _points.add(wall.scaledStart!.center);
      _ends.add(wall.scaledStart as Corner);
      _ends.add(wall.scaledEnd as Corner);
    }
    if (addInfront) {
      _points.insert(0, wall.scaledStart!.center);
      _ends[0] = wall.scaledStart as Corner;
    } else {
      _points.add(wall.scaledEnd!.center);
      _ends[1] = wall.scaledEnd as Corner;
    }
  }

  List<Offset> finishArea() {
    if (_points.length > 1 && _points.last != _points[_points.length - 2]) {
      _points.add(_points.first);
      List<Offset> area = List.from(_points);
      _points.clear();
      isDrawing = false;
      selectedCorner = null;
      return area;
    }
    return List.empty();
  }

  void undo() {
    //TODO: mit WALLID
  }

  Corner? detectClickedCorner(Offset location) {
    for (Corner corner in _ends) {
      if (corner.contains(location)) {
        corner.selected = true;
        return corner;
      }
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_points.isEmpty) {
      return;
    }

    const pointMode = PointMode.polygon;
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(pointMode, _points, paint);

    for (Corner corner in _ends) {
      if (selectedCorner != null && corner.center == selectedCorner!.center) {
        corner.selected = true;
      }
      corner.paintHB(canvas);
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return false;
  }
}
