import 'dart:math';

import 'package:flutter/material.dart';

class SliderHitBox {
  final double radius;
  final double hitBoxSize; //Relative to radius
  late double innerRadius;
  late double outerRadius;
  final double range;
  final double centerAngle;
  final Path outerCircle = Path();

  SliderHitBox(
      {required this.radius,
      this.hitBoxSize = 0.1,
      this.range = 360,
      this.centerAngle = 0}) {
    innerRadius = radius - (3 * radius * hitBoxSize);
    Radius arcInnerRadius = Radius.circular(innerRadius);

    double maxVal = (range / 2) + (range / 2 * hitBoxSize);

    Offset startInner = calcPointFromAngle((centerAngle + maxVal), innerRadius);

    Offset centerInner = calcPointFromAngle(centerAngle, innerRadius);

    Offset endInner = calcPointFromAngle((centerAngle - maxVal), innerRadius);

    outerRadius = radius + (radius * hitBoxSize);
    Radius arcOuterRadius = Radius.circular(outerRadius);

    Offset startOuter = calcPointFromAngle((centerAngle + maxVal), outerRadius);

    Offset centerOuter = calcPointFromAngle(centerAngle, outerRadius);

    Offset endOuter = calcPointFromAngle((centerAngle - maxVal), outerRadius);

    outerCircle.moveTo(startInner.dx, startInner.dy);
    outerCircle.lineTo(startOuter.dx, startOuter.dy);
    outerCircle.arcToPoint(centerOuter, radius: arcOuterRadius);
    outerCircle.arcToPoint(endOuter, radius: arcOuterRadius);
    outerCircle.lineTo(endInner.dx, endInner.dy);
    outerCircle.arcToPoint(centerInner,
        radius: arcInnerRadius, clockwise: false);
    outerCircle.arcToPoint(startInner,
        radius: arcInnerRadius, clockwise: false);
  }

  Offset calcPointFromAngle(double angle, double circleRadius) {
    //x = sin
    double x = sin(angle * (pi / 180)) * circleRadius * -1;
    //y = cos
    double y = cos(angle * (pi / 180)) * circleRadius * -1;

    return Offset(x, y);
  }

  bool isInsideBounds(Offset point) {
    return outerCircle.contains(point);
  }
}
