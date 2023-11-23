import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_test_diplom/paint/CircleSlider/sliderHitbox.dart';

class SliderPainter extends CustomPainter {
  final ValueNotifier<int> repaint;
  final double radius;
  final double hitboxSize;
  late double centerAngle;
  final double maxAngle;
  final bool isFirstWall;
  Path path = Path();
  late SliderHitBox hitBox;
  double val = 0;

  SliderPainter(
      {required this.repaint,
      this.radius = 50,
      this.hitboxSize = 0.1,
      this.centerAngle = 0,
      this.maxAngle = 150,
      this.isFirstWall = false})
      : super(repaint: repaint) {
    centerAngle = -centerAngle;
    val = centerAngle;

    hitBox = SliderHitBox(
        radius: radius,
        hitBoxSize: hitboxSize,
        centerAngle: centerAngle,
        range: maxAngle * 2);

    final arcRadius = Radius.circular(radius);

    if (isFirstWall) {
      path.moveTo(0, -radius);
      path.arcToPoint(Offset(0, radius), radius: arcRadius);
      path.arcToPoint(Offset(0, -radius), radius: arcRadius);
    } else {
      //x = sin
      double centerX = sin(centerAngle * (pi / 180)) * radius * -1;
      //y = cos
      double centerY = cos(centerAngle * (pi / 180)) * radius * -1;

      //print("start - X|" + centerX.toString() + " Y|" + centerY.toString());

      path.moveTo(centerX, centerY);

      //x = sin
      double x = sin((centerAngle + maxAngle) * (pi / 180)) * radius * -1;
      //y = cos
      double y = cos((centerAngle + maxAngle) * (pi / 180)) * radius * -1;

      //print("count - X|" + x.toString() + " Y|" + y.toString());

      path.arcToPoint(Offset(x, y), radius: arcRadius, clockwise: false);

      path.moveTo(centerX, centerY);

      //x = sin
      x = sin((centerAngle - maxAngle) * (pi / 180)) * radius * -1;
      //y = cos
      y = cos((centerAngle - maxAngle) * (pi / 180)) * radius * -1;

      //print("clock - X|" + x.toString() + " Y|" + y.toString());

      path.arcToPoint(Offset(x, y), radius: arcRadius);

      path.moveTo(centerX, centerY);

      path.lineTo(centerX / 2, centerY / 2);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);

    //canvas.drawPath(hitBox.innerCircle, paint);
    //canvas.drawPath(hitBox.outerCircle, paint);

    paint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    // canvas.drawPath(hitBox.innerCircle, paint);
    canvas.drawPath(hitBox.outerCircle, paint);

    paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(
        PointMode.points, [hitBox.calcPointFromAngle(val, radius)], paint);
  }

  void updateValueWithPoint(Offset point) {
    //print(point);
    //points.add(point);

    repaint.value++;

    if (isInsideBounds(point)) {
      //print("inside");
      PathMetrics pathMetrics = path.computeMetrics();

      double minDistance = double.infinity;
      Offset minPOS = Offset.zero;

      pathMetrics.toList().forEach((element) {
        for (var i = 0; i < element.length; i++) {
          Tangent? tangent = element.getTangentForOffset(i.toDouble());
          if (tangent != null) {
            Offset pos = tangent.position;

            double dx = pos.dx - point.dx;
            double dy = pos.dy - point.dy;
            double distance = sqrt(dx * dx + dy * dy).abs();

            if (distance < minDistance) {
              //print(distance);
              minDistance = distance;
              minPOS = pos;
            }
          }
        }
      });
      double angle = atan(minPOS.dx / minPOS.dy);
      val = angle * (180 / pi);
      val = val.roundToDouble();
      if (minPOS.dy >= 0) {
        val -= 180;
        if (minPOS.dx < 0) {
          val = val + 360;
        }
      }
    }
  }

  bool isInsideBounds(Offset point) {
    return hitBox.isInsideBounds(point);
  }

  void updateValueWithAngle(double angle) {
    val = -angle;
  }

  @override
  bool shouldRepaint(SliderPainter oldDelegate) {
    return false;
  }
}
