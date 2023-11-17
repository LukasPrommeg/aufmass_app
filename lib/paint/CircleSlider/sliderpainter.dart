import 'package:flutter/material.dart';

class SliderPainter extends CustomPainter {
  final double radius;
  final double centerAngle;
  final double maxAngle;
  Path path = Path();

  SliderPainter({this.radius = 50, this.centerAngle = 0, this.maxAngle = 150}) {
    final arcRadius = Radius.circular(radius);
    /*
    path.moveTo(radius, 0);
    path.arcToPoint(Offset((2 * radius), radius), radius: arcRadius);
    path.arcToPoint(Offset(radius, (2 * radius)), radius: arcRadius);
    path.arcToPoint(Offset(0, radius), radius: arcRadius);
    path.arcToPoint(Offset(radius, 0), radius: arcRadius);*/
    path.moveTo(0, 0);
    path.arcToPoint(Offset(0, (2 * radius)), radius: arcRadius);
    path.arcToPoint(Offset(0, 0), radius: arcRadius);
    /*path.arcToPoint(Offset(radius, radius), radius: arcRadius);
    path.arcToPoint(Offset(0, (2 * radius)), radius: arcRadius);
    path.arcToPoint(Offset(-radius, radius), radius: arcRadius);
    path.arcToPoint(Offset(0, 0), radius: arcRadius);*/
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
