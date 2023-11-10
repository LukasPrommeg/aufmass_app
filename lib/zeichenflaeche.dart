import 'package:flutter/material.dart';
import 'linepainter.dart';

class PlanCanvas extends StatefulWidget {
  PlanCanvas({
    super.key,
    required this.linePainter,
    required this.polyPainter,
    });
  
  final LinePainter linePainter;
  final LinePainter polyPainter;
  


  @override
  State<PlanCanvas> createState() => _PlanCanvasState(linePainter, polyPainter);
}

class _PlanCanvasState extends State<PlanCanvas> {
  LinePainter _linePainter = LinePainter();
  LinePainter _polyPainter = LinePainter();

  _PlanCanvasState(LinePainter line, LinePainter poly) {
    this._linePainter = line;
    this._polyPainter = poly;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: _linePainter, 
        ),
        CustomPaint(
          painter: _polyPainter,
        ),
      ],
    );
  }

  
}
