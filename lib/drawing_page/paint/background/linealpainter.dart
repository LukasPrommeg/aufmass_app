import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class LinealPainter extends CustomPainter {
  LinealPainter({required Listenable repaint}) : super(repaint: repaint);
  Scale scale = Scale(value: 100);
  Size backgroundSize = const Size(1000, 1000);

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(LinealPainter oldDelegate) {
    return true;
  }
}
