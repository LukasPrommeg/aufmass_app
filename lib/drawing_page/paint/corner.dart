import 'package:flutter/material.dart';

class Corner {
  late Path path;
  final Offset center;
  bool selected = false;

  Corner({required this.center}) {
    const radius = Radius.circular(10);

    path = Path();
    path.moveTo(center.dx, center.dy - 10);
    path.arcToPoint(Offset(center.dx + 10, center.dy), radius: radius);
    path.arcToPoint(Offset(center.dx, center.dy + 10), radius: radius);
    path.arcToPoint(Offset(center.dx - 10, center.dy), radius: radius);
    path.arcToPoint(Offset(center.dx, center.dy - 10), radius: radius);
  }
}
