import 'dart:math';
import 'dart:ui';
import 'package:aufmass_app/Einheiten/einheitcontroller.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/2D_Objects/clickable.dart';
import 'package:aufmass_app/2D_Objects/corner.dart';

const double hbSizeDefine = 10;

class Wall extends ClickAble {
  String uuid = UniqueKey().toString();
  final double angle;
  final double length;
  late Corner start;
  late Corner end;
  int id = 0;

  Wall({required this.angle, required this.length, required this.start, required this.end}) : super(hbSize: hbSizeDefine);

  Wall.clone(Wall wall) : this(angle: wall.angle, length: wall.length, start: wall.start, end: wall.end);

  Wall.fromStart({required this.angle, required this.length, required this.start}) : super(hbSize: hbSizeDefine) {
    //x = sin
    double x = -sin(angle * (pi / 180)) * length * -1;
    //y = cos
    double y = cos(angle * (pi / 180)) * length * -1;

    end = Corner.fromPoint(point: start.point + Offset(x, y));

    size = size.expandToInclude(Rect.fromPoints(start.point, end.point));
  }

  Wall.fromEnd({required this.angle, required this.length, required this.end}) : super(hbSize: hbSizeDefine) {
    //x = sin
    double x = -sin(angle * (pi / 180)) * length * -1;
    //y = cos
    double y = cos(angle * (pi / 180)) * length * -1;

    start = Corner.fromPoint(point: end.point - Offset(x, y));

    size = size.expandToInclude(Rect.fromPoints(start.point, end.point));
  }

  ClickAble? findClickedPart(Offset position) {
    if (start.contains(position)) {
      return start;
    } else if (end.contains(position)) {
      return end;
    } else if (contains(position)) {
      return this;
    } else {
      return null;
    }
  }

  @override
  void calcHitbox() {
    if (start.scaled != null && end.scaled != null) {
      Offset diff = end.scaled! - start.scaled!;

      double calcAngle = atan(diff.dy / diff.dx);

      hitbox = Path();
      //x = sin
      double x = -sin(calcAngle) * hbSize * -1;
      //y = cos
      double y = cos(calcAngle) * hbSize * -1;

      Offset endOffset = Offset(x, y);

      List<Offset> points = [];

      points.add(start.scaled! + endOffset);
      points.add(start.scaled! - endOffset);
      points.add(end.scaled! - endOffset);
      points.add(end.scaled! + endOffset);

      hitbox.addPolygon(points, true);
    }
  }

  @override
  void initScale(double scale, Offset center) {
    start.initScale(scale, center);
    end.initScale(scale, center);

    posBeschriftung = (end.scaled! - start.scaled!) / 2 + start.scaled!;

    super.initScale(scale, center);
  }

  @override
  void paint(Canvas canvas, Color color, double size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = size
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(PointMode.lines, [start.scaled!, end.scaled!], paint);
  }

  @override
  void paintBeschriftung(Canvas canvas, Color color, String text, double size) {
    canvas.save();
    canvas.translate(posBeschriftung.dx, posBeschriftung.dy);

    double diffx = end.scaled!.dx - start.scaled!.dx;
    double diffy = end.scaled!.dy - start.scaled!.dy;

    double rotationAngle = atan(diffy / diffx);

    canvas.rotate(rotationAngle);
    canvas.translate(-posBeschriftung.dx, -posBeschriftung.dy);

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

    textPainter.paint(canvas, Offset(posBeschriftung.dx - (textPainter.width / 2), posBeschriftung.dy));
    canvas.restore();
  }

  @override
  void paintLaengen(Canvas canvas, Color color, double size) {
    canvas.save();
    canvas.translate(posBeschriftung.dx, posBeschriftung.dy);

    double diffx = end.scaled!.dx - start.scaled!.dx;
    double diffy = end.scaled!.dy - start.scaled!.dy;

    double rotationAngle = atan(diffy / diffx);

    canvas.rotate(rotationAngle);
    canvas.translate(-posBeschriftung.dx, -posBeschriftung.dy);

    TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: "${EinheitController().convertToSelected(length).toStringAsFixed(2)}${EinheitController().selectedEinheit.name}",
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(canvas, Offset(posBeschriftung.dx - (textPainter.width / 2), posBeschriftung.dy - textPainter.height));
    canvas.restore();
  }
}
