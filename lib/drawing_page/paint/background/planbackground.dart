import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/background/linealpainter.dart';
import 'package:flutter_test_diplom/drawing_page/paint/background/rasterpainter.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class PlanBackground extends StatelessWidget {
  const PlanBackground({super.key});

  void updateScale(Scale scale) {}

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: LinealPainter(),
      painter: RasterPainter(),
    );
  }
}
