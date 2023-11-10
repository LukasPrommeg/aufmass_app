import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/paintcontroller.dart';

class PlanCanvas extends StatelessWidget {
  PlanCanvas({
    super.key,
    required this.paintController,
  });

  final PaintController paintController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: paintController.linePainter,
        ),
        CustomPaint(
          painter: paintController.polyPainter,
        ),
      ],
    );
  }
}
