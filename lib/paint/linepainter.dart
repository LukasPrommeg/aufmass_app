import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  List<Offset> _points = [];
  bool isDrawing = false;

  void addPoint(Offset newPos) {
    if(_points.isEmpty) {
      isDrawing = true;
    }
    _points.add(newPos);
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
      return area;
    }
    return List.empty();
  }

  void undo() {
    if (_points.isEmpty) {
      return;
    }
    if (_points.length == 2) {
      _points.removeLast();
      isDrawing = false;
    }
    _points.removeLast();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if(_points.isEmpty) {
      return;
    }

    const pointMode = ui.PointMode.polygon;
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(pointMode, _points, paint);

    paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(ui.PointMode.points, [_points.last], paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return false;
  }
}
