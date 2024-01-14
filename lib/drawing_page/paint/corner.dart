import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aufmass_app/Misc/clickable.dart';

const double hbSizeDefine = 20;

class Corner extends ClickAble {
  final Offset point;
  Offset? scaled;
  late Path path;

  Corner({required this.point, required this.scaled, required this.path}) : super(hbSize: hbSizeDefine);

  Corner.fromPoint({required this.point, double hitboxSize = hbSizeDefine}) : super(hbSize: hitboxSize) {
    path = Path();
    Radius radius = Radius.circular(hbSize);

    path.moveTo(0, 0 - hbSize);
    path.arcToPoint(Offset(hbSize, 0), radius: radius);
    path.arcToPoint(Offset(0, hbSize), radius: radius);
    path.arcToPoint(Offset(-hbSize, 0), radius: radius);
    path.arcToPoint(Offset(0, -hbSize), radius: radius);

    size = size.expandToInclude(Rect.fromPoints(point, point));
  }

  Corner.clone(Corner corner) : this(point: corner.point, scaled: corner.scaled, path: corner.path);

  @override
  @protected
  void calcHitbox() {
    if (scaled != null) {
      hitbox = path;
      offset = Offset.zero;
      moveTo(scaled!);
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
