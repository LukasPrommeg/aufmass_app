import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class PlanCanvas extends StatelessWidget {
  final PaintController paintController;

  const PlanCanvas({
    super.key,
    required this.paintController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        paintController.canvasSize = canvasSize;
        return CustomPaint(
          painter: paintController.polyPainter,
          foregroundPainter: paintController.linePainter,
        );
      },
    );
  }
}
