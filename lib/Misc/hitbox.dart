import 'dart:math';

import 'package:flutter/material.dart';

abstract class ClickAble {
  Path hitbox = Path();
  double size = 10;
  Offset offset = Offset.zero;
  Paint paintStyle = Paint()
    ..color = Colors.red
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;

  ClickAble({required this.size});

  ClickAble.fromWall(
      {required double angle, required double length, required this.size}) {
//x = sin
    double x = -sin(angle * (pi / 180)) * length * -1;
    //y = cos
    double y = cos(angle * (pi / 180)) * length * -1;

    Offset wallEnd = Offset(x, y);

    //x = sin
    x = -sin(angle * (pi / 180)) * size * -1;
    //y = cos
    y = cos(angle * (pi / 180)) * size * -1;

    Offset endOffset = Offset(x, y);

    hitbox.moveTo(endOffset.dx, endOffset.dy);
    hitbox.lineTo(-endOffset.dx, -endOffset.dy);
    hitbox.lineTo(wallEnd.dx - endOffset.dx, wallEnd.dy - endOffset.dy);
    hitbox.lineTo(wallEnd.dx + endOffset.dx, wallEnd.dy + endOffset.dy);
  }

  ClickAble.fromPoint({required Offset point, required this.size}) {
    Radius radius = Radius.circular(size);

    hitbox.moveTo(0, 0 - size);
    hitbox.arcToPoint(const Offset(10, 0), radius: radius);
    hitbox.arcToPoint(const Offset(0, 10), radius: radius);
    hitbox.arcToPoint(const Offset(-10, 0), radius: radius);
    hitbox.arcToPoint(const Offset(0, -10), radius: radius);

    shift(point);
  }

  ClickAble.merge(ClickAble a, ClickAble b, [double? size]) {
    if (size != null) {
      this.size = size;
    }
    //TODO: Merge Hitboxes
  }

  bool contains(Offset position) {
    if (hitbox.contains(position)) {
      return true;
    } else {
      return false;
    }
  }

  void shift(Offset offset) {
    offset += this.offset;
    this.offset = offset;
    hitbox = hitbox.shift(this.offset);
  }

  void paint(Canvas canvas) {
    shift(-offset);
    Paint areaPaint = Paint()
      ..color = paintStyle.color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    print(hitbox.getBounds());
    canvas.drawPath(hitbox, areaPaint);
    canvas.drawPath(hitbox, paintStyle);
  }
}
