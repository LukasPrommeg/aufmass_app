import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitcontroller.dart';
import 'package:aufmass_app/PlanPage/Paint/paintcontroller.dart';

class RasterPainter extends CustomPainter {
  RasterPainter({required Listenable repaint}) : super(repaint: repaint);
  ScalingData scalingData = ScalingData(
      scale: double.infinity, rect: Rect.largest, center: Offset.zero);
  Size backgroundSize = const Size(1000, 1000);

  @override
  void paint(Canvas canvas, Size size) {
    double pxPerGrid = 100;
    Offset upperLeftCorner = Offset.zero;
    List<Offset> pointsX = [];
    List<Offset> pointsY = [];

    const pointMode = PointMode.lines;
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.5
      ..strokeCap = StrokeCap.round;

    if (scalingData.scale.isInfinite) {
      pxPerGrid = min(backgroundSize.width, backgroundSize.height) / 3;
    } else {
      upperLeftCorner =
          scalingData.rect.topLeft * scalingData.scale - scalingData.center;
      pxPerGrid =
          scalingData.scale * (120 * pow(scalingData.scale, -1) as double);
    }

    //Vertikale Linien
    for (double x = upperLeftCorner.dx;
        x < backgroundSize.width;
        x += pxPerGrid) {
      pointsX.add(Offset(x, 0));
      pointsX.add(Offset(x, backgroundSize.height));
    }
    for (double x = upperLeftCorner.dx; x > 0; x -= pxPerGrid) {
      pointsX.add(Offset(x, 0));
      pointsX.add(Offset(x, backgroundSize.height));
    }

    //Horizontale Linien
    for (double y = upperLeftCorner.dy;
        y < backgroundSize.height;
        y += pxPerGrid) {
      pointsY.add(Offset(0, y));
      pointsY.add(Offset(backgroundSize.width, y));
    }
    for (double y = upperLeftCorner.dy; y > 0; y -= pxPerGrid) {
      pointsY.add(Offset(0, y));
      pointsY.add(Offset(backgroundSize.width, y));
    }

    canvas.drawPoints(pointMode, pointsX, paint);
    canvas.drawPoints(pointMode, pointsY, paint);

    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 10,
      backgroundColor: Colors.white,
    );

    double offset = 15;

    //Beschriftung X
    for (Offset point in pointsX) {
      double val = EinheitController().convertToSelected(
          (point.dx - upperLeftCorner.dx) / scalingData.scale);

      final textSpan = TextSpan(
        text:
            "${val.toStringAsFixed(2).toString()}${EinheitController().selectedEinheit.name}",
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      Offset textPoint = Offset.zero;

      if (point.dy > 0) {
        textPoint = Offset(point.dx, point.dy - offset) -
            Offset((textPainter.width / 2), 0);
      } else {
        textPoint = Offset(point.dx, point.dy + offset) -
            Offset((textPainter.width / 2), textPainter.height);
      }
      textPainter.paint(canvas, textPoint);
    }

    //Beschriftung Y
    for (Offset point in pointsY) {
      double val = EinheitController().convertToSelected(
          (point.dy - upperLeftCorner.dy) / scalingData.scale);

      final textSpan = TextSpan(
        text:
            "${val.toStringAsFixed(2).toString()}${EinheitController().selectedEinheit.name}",
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      Offset textPoint = Offset.zero;

      if (point.dx > 0) {
        textPoint = Offset(point.dx - offset, point.dy) -
            Offset(textPainter.width, textPainter.height / 2);
      } else {
        textPoint = Offset(point.dx + offset, point.dy) -
            Offset(0, textPainter.height / 2);
      }
      textPainter.paint(canvas, textPoint);
    }
  }

  @override
  bool shouldRepaint(RasterPainter oldDelegate) {
    return true;
  }
}
