import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class LinealPainter extends CustomPainter {
  LinealPainter({required Listenable repaint}) : super(repaint: repaint);
  ScalingData scalingData = ScalingData(
      scale: double.infinity, rect: Rect.largest, center: Offset.zero);
  Size backgroundSize = const Size(1000, 1000);

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(LinealPainter oldDelegate) {
    return true;
  }
}
