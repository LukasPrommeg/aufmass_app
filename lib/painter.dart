import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class MyPainter extends CustomPainter {
  final List<Offset> _points = [];
  final List<int> firstIndexOfArea = [];

  MyPainter() {
    firstIndexOfArea.add(0);
  }

  void addPoint(Offset newPos) {
    if (_points.length != firstIndexOfArea.last &&
        _points.length != firstIndexOfArea.last + 1) {
      _points.add(_points.last);
    }
    _points.add(newPos);
  }

  void finishArea() {
    if (_points.length != firstIndexOfArea) {
      _points.add(_points.last);
      _points.add(_points[firstIndexOfArea.last]);
      firstIndexOfArea.add(_points.length);
    }
  }

  void undo() {
    if (_points.isEmpty) {
      return;
    }
    if (firstIndexOfArea.last == _points.length) {
      firstIndexOfArea.removeLast();
    }
    _points.removeLast();
    _points.removeLast();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pointMode = ui.PointMode.lines;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(pointMode, _points, paint);
  }

  @override
  bool shouldRepaint(MyPainter old) {
    return true;
  }
}
