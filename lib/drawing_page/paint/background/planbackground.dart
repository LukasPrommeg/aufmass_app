import 'package:flutter/material.dart';
import 'package:aufmass_app/drawing_page/paint/background/rasterpainter.dart';
import 'package:aufmass_app/drawing_page/paint/paintcontroller.dart';

//ignore: must_be_immutable
class PlanBackground extends StatelessWidget {
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);

  late RasterPainter rasterPainter;

  PlanBackground({super.key}) {
    rasterPainter = RasterPainter(repaint: _repaint);
  }

  void updateScaleAndRect(ScalingData scale) {
    if (scale.scale.isFinite) {
      rasterPainter.scalingData = scale;
    }

    _repaint.value++;
  }

  void updateSize(Size size) {
    rasterPainter.backgroundSize = size;

    _repaint.value++;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: rasterPainter,
    );
  }
}
