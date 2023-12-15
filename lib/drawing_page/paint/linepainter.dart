import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/corner.dart';
import 'package:flutter_test_diplom/drawing_page/paint/wall.dart';

class LinePainter extends CustomPainter {
  LinePainter({required Listenable repaint}) : super(repaint: repaint);

  List<Offset> _points = [];
  final List<Corner> _ends = [];
  bool isDrawing = false;

  Corner? selectedCorner;

  Offset testCenter = Offset.zero;
  Rect testRect = Rect.zero;

  /*List<Offset>? drawPoint(Offset location) {
    Corner? clickedCorner = detectClickedCorner(location);

    if (isDrawing && selectedCorner == null) {
      selectedCorner = clickedCorner;
    } else if (selectedCorner != null &&
        clickedCorner?.center == selectedCorner?.center) {
      selectedCorner = null;
    } else if (clickedCorner != null &&
        selectedCorner?.center != clickedCorner.center) {
      selectedCorner = clickedCorner;
      return finishArea();
    } else {
      selectedCorner = addCorner(location, selectedCorner?.center);
    }
    return null;
  }
  
  Corner? addCorner(Offset to, Offset? from) {
    if (_points.isEmpty) {
      isDrawing = true;
      _points.add(to);
      return Corner(center: to);
    } else if (from != null && from == _points.first) {
      _points.insert(0, to);
      return Corner(center: to);
    } else if (from != null && from == _points.last) {
      _points.add(to);
      return Corner(center: to);
    }
    return null;
  }*/

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

  void drawFinishedArea(List<Offset> area) {
    isDrawing = true;
    _points = List.from(area);
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
    if (_points.isEmpty) {
      return;
    }
    if (selectedCorner != null) {
      selectedCorner = null;
      return;
    }
    if (_points.length == 2) {
      _points.removeLast();
    }
    _points.removeLast();
    if (_points.isEmpty) {
      isDrawing = false;
    }
  }

  Corner? detectClickedCorner(Offset location) {
    for (Corner corner in _ends) {
      if (corner.path.contains(location)) {
        corner.selected = false;
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

    const pointMode = ui.PointMode.polygon;
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(pointMode, _points, paint);

    for (Corner corner in _ends) {
      if (selectedCorner != null && corner.center == selectedCorner?.center) {
        paint = Paint()
          ..color = Colors.green
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
      } else {
        paint = Paint()
          ..color = Colors.red
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
      }
      canvas.drawPath(corner.path, paint);
    }

    paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(
        ui.PointMode.points, [_points.first, _points.last], paint);

    paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(ui.PointMode.points, [testCenter], paint);

    paint = Paint()
      ..color = Color(0xff638965)
      ..style = PaintingStyle.stroke;
    canvas.drawRect(testRect, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return false;
  }
}
