import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class PlanCanvas extends StatelessWidget {
  const PlanCanvas({
    super.key,
    required this.paintController,
  });

  final PaintController paintController;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: paintController.polyPainter,
      foregroundPainter: paintController.linePainter,
    );
  }
}
