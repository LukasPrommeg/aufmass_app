import 'dart:math';
import 'package:aufmass_app/PlanPage/2D_Objects/wall.dart';
import 'package:flutter/material.dart';

class PreviewPainter extends CustomPainter {
  Wall infront;
  Wall behind;
  final Path _path = Path();
  Rect reqSize = Rect.zero;
  Rect maxSize = Rect.zero;

  PreviewPainter(Offset leftBottom,
      {required this.infront, required this.behind}) {
    Path path = Path();

    Offset diff = behind.end.point - infront.start.point;

    path.moveTo(infront.start.point.dx, infront.start.point.dy);
    path.arcToPoint(behind.end.point,
        radius: Radius.circular(diff.distance / 2), clockwise: false);

    reqSize = Rect.fromPoints(infront.start.point, infront.end.point);
    reqSize = reqSize
        .expandToInclude(Rect.fromPoints(behind.start.point, behind.end.point));
    reqSize = reqSize.expandToInclude(path.getBounds());

    maxSize = Rect.fromPoints(Offset.zero, leftBottom);

    double maxScaleX = maxSize.width / reqSize.width;
    double maxScaleY = maxSize.height / reqSize.height;

    double scale = min(maxScaleX, maxScaleY);

    reqSize = Rect.fromPoints(infront.start.point, infront.end.point);
    reqSize = reqSize
        .expandToInclude(Rect.fromPoints(behind.start.point, behind.end.point));

    Offset center = reqSize.center * scale - (leftBottom / 2);

    infront.initScale(scale, center);
    behind.initScale(scale, center);

    diff = behind.end.scaled! - infront.start.scaled!;

    _path.moveTo(infront.start.scaled!.dx, infront.start.scaled!.dy);
    _path.arcToPoint(behind.end.scaled!,
        radius: Radius.circular(diff.distance / 2), clockwise: false);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    canvas.drawRect(maxSize, paint);

    infront.paint(canvas, Colors.black, 10);
    behind.paint(canvas, Colors.black, 10);

    paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawPath(_path, paint);
  }

  @override
  bool shouldRepaint(PreviewPainter oldDelegate) {
    return false;
  }
}
