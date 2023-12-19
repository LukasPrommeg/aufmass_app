import 'dart:math';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/Misc/hitbox.dart';
import 'package:flutter_test_diplom/drawing_page/paint/corner.dart';

class Wall extends ClickAble with EventArgs {
  final double angle;
  final double length;
  bool selected = false;
  late Offset end;
  Corner? _scaledStart;
  Corner? scaledEnd;
  int id = 0;

  set scaledStart(Corner? corner) {
    if (corner != null) {
      shift(corner.center);
    }
    _scaledStart = corner;
  }

  Corner? get scaledStart {
    return _scaledStart;
  }

  Wall({required this.angle, required this.length})
      : super.fromWall(angle: angle, length: length, size: 10) {
    //x = sin
    double x = -sin(angle * (pi / 180)) * length * -1;
    //y = cos
    double y = cos(angle * (pi / 180)) * length * -1;

    end = Offset(x, y);
  }

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
