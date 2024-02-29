import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/clickable.dart';

const double hbSizeDefine = 20;

class Punkt extends ClickAble {
  final Offset point;
  Offset? scaled;

  Punkt({required this.point, required this.scaled}) : super(hbSize: hbSizeDefine);

  Punkt.fromPoint({required this.point, double hitboxSize = hbSizeDefine}) : super(hbSize: hitboxSize) {
    size = size.expandToInclude(Rect.fromPoints(point, point));
  }

  Punkt.clone(Punkt corner) : this(point: corner.point, scaled: corner.scaled);

  bool equals(Punkt other) {
    if (point.dx.roundToDouble() == other.point.dx.roundToDouble() && point.dy.roundToDouble() == other.point.dy.roundToDouble()) {
      return true;
    } else {
      return false;
    }
  }

  Offset getRounded() {
    double dx = double.parse(point.dx.toStringAsFixed(2));
    double dy = double.parse(point.dy.toStringAsFixed(2));

    return Offset(dx, dy);
  }

  @override
  @protected
  void calcHitbox() {
    if (scaled != null) {
      Radius radius = Radius.circular(hbSize);

      hitbox.moveTo(scaled!.dx, scaled!.dy - hbSize);
      hitbox.arcToPoint(Offset(scaled!.dx + hbSize, scaled!.dy), radius: radius);
      hitbox.arcToPoint(Offset(scaled!.dx, scaled!.dy + hbSize), radius: radius);
      hitbox.arcToPoint(Offset(scaled!.dx - hbSize, scaled!.dy), radius: radius);
      hitbox.arcToPoint(Offset(scaled!.dx, scaled!.dy - hbSize), radius: radius);
    }
  }

  @override
  void initScale(double scale, Offset center) {
    scaled = (point * scale) - center;
    super.initScale(scale, center);
  }

  @override
  void paint(Canvas canvas, Color color, double size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = size
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(PointMode.points, [scaled!], paint);
  }

  @override
  void paintBeschriftung(Canvas canvas, Color color, String text, double size) {
    TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    textPainter.paint(canvas, Offset(scaled!.dx - (textPainter.width / 2), scaled!.dy - textPainter.height));
  }

  @override
  void paintLaengen(Canvas canvas, Color color, double size) {}
}
