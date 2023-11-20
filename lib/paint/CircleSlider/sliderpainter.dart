import 'package:flutter/material.dart';
import 'dart:math';

class SliderPainter extends CustomPainter {
  /*final*/ double radius;
  /*final*/ double centerAngle;
  /*final*/ double maxAngle;
  Path path = Path();

  SliderPainter({this.radius = 50, this.centerAngle = 0, this.maxAngle = 150}) {
    final arcRadius = Radius.circular(radius);
    
    //x = sin
    double centerX = sin(centerAngle * (pi / 180)) * radius * - 1;
    //y = cos
    double centerY = cos(centerAngle * (pi / 180)) * radius * - 1;

    //print("start - X|" + centerX.toString() + " Y|" + centerY.toString());

    path.moveTo(centerX, centerY);

    //x = sin
    double x = sin((centerAngle + maxAngle) * (pi / 180)) * radius * - 1;
    //y = cos
    double y = cos((centerAngle + maxAngle) * (pi / 180)) * radius * - 1;

    //print("count - X|" + x.toString() + " Y|" + y.toString());

    path.arcToPoint(Offset(x,  y), radius: arcRadius, clockwise: false);

    path.moveTo(centerX, centerY);

    //x = sin
    x = sin((centerAngle - maxAngle) * (pi / 180)) * radius * - 1;
    //y = cos
    y = cos((centerAngle - maxAngle) * (pi / 180)) * radius * - 1;

    //print("clock - X|" + x.toString() + " Y|" + y.toString());

    path.arcToPoint(Offset(x,  y), radius: arcRadius);

    path.moveTo(centerX, centerY);

    path.lineTo(centerX / 2, centerY / 2);

  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SliderPainter oldDelegate) {
    return false;
  }
}
