import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/Misc/hitbox.dart';

class Corner extends ClickAble {
  final Offset center;
  bool selected = false;

  Corner({required this.center, double hitboxSize = 10})
      : super.fromPoint(point: center, size: hitboxSize);

  @override
  void paint(Canvas canvas) {
    Paint paintStyle;

    if (selected) {
      paintStyle = Paint()
        ..color = Colors.green
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;
    } else {
      paintStyle = Paint()
        ..color = Colors.red
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;
    }

    super.paintStyle = paintStyle;

    super.paint(canvas);
  }
}
