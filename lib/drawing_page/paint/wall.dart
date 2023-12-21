import 'dart:math';
import 'package:flutter/material.dart';
import 'package:aufmass_app/Misc/clickable.dart';
import 'package:aufmass_app/drawing_page/paint/corner.dart';

class Wall extends ClickAble {
  final double angle;
  final double length;
  late Offset end;
  Corner? _scaledStart;
  Corner? scaledEnd;
  int id = 0;

  set scaledStart(Corner? corner) {
    if (corner != null) {
      moveTo(corner.center);
    }
    _scaledStart = corner;
  }

  Corner? get scaledStart {
    return _scaledStart;
  }

  Wall({required this.angle, required this.length}) : super(hbSize: 10) {
    //x = sin
    double x = -sin(angle * (pi / 180)) * length * -1;
    //y = cos
    double y = cos(angle * (pi / 180)) * length * -1;

    end = Offset(x, y);
  }

  @override
  @protected
  void calcHitbox() {
    if (scaledStart != null && scaledEnd != null) {
      Offset diff = scaledEnd!.center - scaledStart!.center;

      double calcAngle = atan(diff.dy / diff.dx);

      hitbox = Path();
      //x = sin
      double x = -sin(calcAngle) * hbSize * -1;
      //y = cos
      double y = cos(calcAngle) * hbSize * -1;

      Offset endOffset = Offset(x, y);

      List<Offset> points = [];

      points.add(scaledStart!.center + endOffset);
      points.add(scaledStart!.center - endOffset);
      points.add(scaledEnd!.center - endOffset);
      points.add(scaledEnd!.center + endOffset);

      hitbox.addPolygon(points, true);
    }
  }
}
