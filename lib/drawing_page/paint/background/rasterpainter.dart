import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class RasterPainter extends CustomPainter {
  Scale scale = Scale(value: 1);

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(RasterPainter oldDelegate) {
    return true;
  }
}
