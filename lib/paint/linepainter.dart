import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/paint/corner.dart';

class LinePainter extends CustomPainter {
  LinePainter({required Listenable repaint}) : super(repaint: repaint);

  List<Offset> _points = [];
  List<Corner> _ends = [];
  bool isDrawing = false;
  Corner? selectedCorner;
  //Event repaint;

  List<Offset>? drawPoint(Offset location) {
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
      selectedCorner = addWall(location, selectedCorner?.center);
    }
    return null;
  }

  Corner? addWall(Offset to, Offset? from) {
    if (_points.isEmpty) {
      isDrawing = true;
      _points.add(to);
      return Corner(path: Path(), center: to);
    } else if (from != null && from == _points.first) {
      _points.insert(0, to);
      return Corner(path: Path(), center: to);
    } else if (from != null && from == _points.last) {
      _points.add(to);
      return Corner(path: Path(), center: to);
    } else {
      print("THIS SHOULDNT BE POSSIBLE");
      //_points.add(to);
    }
    return null;
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

    const radius = Radius.circular(10);

    _ends.clear();

    for (Offset point in [_points.first, _points.last]) {
      if (selectedCorner != null && point == selectedCorner?.center) {
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

      Path path = Path();
      path.moveTo(point.dx, point.dy - 10);
      path.arcToPoint(Offset(point.dx + 10, point.dy), radius: radius);
      path.arcToPoint(Offset(point.dx, point.dy + 10), radius: radius);
      path.arcToPoint(Offset(point.dx - 10, point.dy), radius: radius);
      path.arcToPoint(Offset(point.dx, point.dy - 10), radius: radius);

      canvas.drawPath(path, paint);
      _ends.add(Corner(path: path, center: point));
    }

    paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(
        ui.PointMode.points, [_points.first, _points.last], paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return false;
  }
}
