import 'package:event/event.dart';
import 'package:flutter/material.dart';

abstract class ClickAble extends EventArgs {
  Path hitbox = Path();
  double hbSize = 10;
  bool selected = false;
  Offset posBeschriftung = const Offset(0, 0);
  Rect size = Rect.zero;

  @protected
  Offset offset = Offset.infinite;

  Paint _paintStyle = Paint()
    ..color = Colors.red
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;

  ClickAble({required this.hbSize});

  ClickAble.merge(ClickAble a, ClickAble b, [double? size]) {
    if (size != null) {
      hbSize = size;
    }
    //TODO: Maybe merge Hitboxes
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

  void paintHB(Canvas canvas) {
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

  void paint(Canvas canvas, String name, Color color, bool beschriftung, double size);

  @protected
  void calcHitbox();

  void initScale(double scale, Offset center);
}
