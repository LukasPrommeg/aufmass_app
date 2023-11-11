import 'package:flutter/material.dart';
import 'paint/linepainter.dart';

class PlanCanvas extends StatelessWidget {
  const PlanCanvas({
    super.key,
    required this.linePainter,
    required this.polyPainter,
  });

  final LinePainter linePainter;
  final LinePainter polyPainter;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: linePainter,
        ),
        CustomPaint(
          painter: polyPainter,
        ),
      ],
    );
  }
}
