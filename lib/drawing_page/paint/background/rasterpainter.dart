import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class RasterPainter extends CustomPainter {
  RasterPainter({required Listenable repaint}) : super(repaint: repaint);
  Scale scale = Scale(value: 100);
  Size backgroundSize = Size(1000, 1000);

  @override
  void paint(Canvas canvas, Size size) {
    double pxPerMeter = scale.value * 1000;
    List<Offset> points = [];

    const pointMode = PointMode.lines;
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    /*for (double x = pxPerMeter; x < backgroundSize.width; x + pxPerMeter) {
      points.add(Offset(x, 0));
      points.add(Offset(x, backgroundSize.height));
    }
    for (double y = pxPerMeter; y < backgroundSize.height; y + pxPerMeter) {
      points.add(Offset(0, y));
      points.add(Offset(backgroundSize.width, y));
    }*/

    canvas.drawPoints(pointMode, points, paint);
  }

  @override
  bool shouldRepaint(RasterPainter oldDelegate) {
    return true;
  }
}
