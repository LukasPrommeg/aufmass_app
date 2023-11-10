import 'package:flutter/material.dart';

class PolyPainter extends CustomPainter {
  final Path _path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;
    canvas.drawPath(_path, paint);
  }

  @override
  bool shouldRepaint(PolyPainter old) {
    return false;
  }
}
