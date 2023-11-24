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
        centerAngle = 270;
    centerAngle = -centerAngle;
    //val = centerAngle;

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
      Offset center = hitBox.calcPointFromAngle(centerAngle, radius);
      path.moveTo(center.dx, center.dy);

      Offset endCClockwise = hitBox.calcPointFromAngle((centerAngle + maxAngle), radius);
      path.arcToPoint(endCClockwise, radius: arcRadius, clockwise: false);

      path.moveTo(center.dx, center.dy);
      
      Offset endClockwise = hitBox.calcPointFromAngle((centerAngle - maxAngle), radius);
      path.arcToPoint(endClockwise, radius: arcRadius);

      path.moveTo(center.dx, center.dy);
      path.lineTo(center.dx / 2, center.dy / 2);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);

    paint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    canvas.drawPath(hitBox.outerCircle, paint);

    paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(
        PointMode.points, [hitBox.calcPointFromAngle(val + centerAngle, radius)], paint);
  }

  void updateValueWithPoint(Offset point) {
    repaint.value++;

    if (isInsideBounds(point)) {
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
              minDistance = distance;
              minPOS = pos;
            }
          }
        }
      });
      double angle = atan(minPOS.dx / minPOS.dy);
      val = angle * (180 / pi);
      print(val);
      val = val.roundToDouble();
      print(val);

      if (minPOS.dy >= 0) {
        val -= 180;
        if (minPOS.dx < 0) {
          val = val + 360;
        }
      }
      val -= centerAngle;
    }
  }

  bool isInsideBounds(Offset point) {
    return hitBox.isInsideBounds(point);
  }

  void updateValueWithAngle(double angle) {
    val = -(angle);
  }

  @override
  bool shouldRepaint(SliderPainter oldDelegate) {
    return false;
  }
}
