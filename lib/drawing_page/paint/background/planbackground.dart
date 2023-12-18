import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/background/linealpainter.dart';
import 'package:flutter_test_diplom/drawing_page/paint/background/rasterpainter.dart';

class PlanBackground extends StatelessWidget {
  const PlanBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: LinealPainter(),
      painter: RasterPainter(),
    );
  }
}
