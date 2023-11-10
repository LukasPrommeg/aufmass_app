import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/linepainter.dart';
import 'package:flutter_test_diplom/polypainter.dart';

class PaintController {
  PolyPainter polyPainter = PolyPainter();
  LinePainter linePainter = LinePainter();

  void drawPoint(Offset pos) {
    linePainter.addPoint(pos);
  }

  void finishArea() {
    linePainter.finishArea();
  }

  void undo() {
    linePainter.undo();
  }
}