import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/background/linealpainter.dart';
import 'package:flutter_test_diplom/drawing_page/paint/background/rasterpainter.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

//ignore: must_be_immutable
class PlanBackground extends StatelessWidget {
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);

  late LinealPainter linealPainter;
  late RasterPainter rasterPainter;

  PlanBackground({super.key}) {
    linealPainter = LinealPainter(repaint: _repaint);
    rasterPainter = RasterPainter(repaint: _repaint);
  }

  void updateScaleAndRect(ScalingData scale) {
    if (scale.scale.isFinite) {
      linealPainter.scalingData = scale;
      rasterPainter.scalingData = scale;
    }

    _repaint.value++;
  }

  void updateSize(Size size) {
    linealPainter.backgroundSize = size;
    rasterPainter.backgroundSize = size;

    _repaint.value++;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: linealPainter,
      painter: rasterPainter,
    );
  }
}
