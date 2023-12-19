import 'package:flutter/material.dart';

abstract class ClickAble {
  Path hitbox = Path();
  double size = 10;
  bool selected = false;

  @protected
  Offset offset = Offset.infinite;

  Paint _paintStyle = Paint()
    ..color = Colors.red
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;

  ClickAble({required this.size});

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

  void moveTo(Offset offset) {
    if (this.offset.isFinite) {
      hitbox = hitbox.shift(-this.offset);
    }
    this.offset = offset;
    hitbox = hitbox.shift(this.offset);
  }

  void paint(Canvas canvas) {
    if (selected) {
      _paintStyle = Paint()
        ..color = Colors.green
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;
    } else {
      _paintStyle = Paint()
        ..color = Colors.red
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;
    }

    Paint areaPaint = Paint()
      ..color = _paintStyle.color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    calcHitbox();

    canvas.drawPath(hitbox, areaPaint);
    canvas.drawPath(hitbox, _paintStyle);
  }

  @protected
  void calcHitbox();
}
