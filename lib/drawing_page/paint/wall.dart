import 'dart:math';

import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/corner.dart';

class Wall extends EventArgs {
  final double angle;
  final double length;
  bool selected = false;
  late Offset end;
  Corner? scaledStart;
  Corner? scaledEnd;

  Wall({required this.angle, required this.length}) {
    //x = sin
    double x = -sin(angle * (pi / 180)) * length * -1;
    //y = cos
    double y = cos(angle * (pi / 180)) * length * -1;

    end = Offset(x, y);
  }
}
