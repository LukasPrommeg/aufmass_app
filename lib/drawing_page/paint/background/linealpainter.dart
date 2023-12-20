import 'package:flutter/material.dart';
import 'package:aufmass_app/drawing_page/paint/paintcontroller.dart';

class LinealPainter extends CustomPainter {
  LinealPainter({required Listenable repaint}) : super(repaint: repaint);
  ScalingData scalingData = ScalingData(scale: double.infinity, rect: Rect.largest, center: Offset.zero);
  Size backgroundSize = const Size(1000, 1000);

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(LinealPainter oldDelegate) {
    return true;
  }
}
