import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/flaeche.dart';
import 'package:flutter_test_diplom/paint/linepainter.dart';
import 'package:flutter_test_diplom/paint/polypainter.dart';

class PaintController {
  final PolyPainter polyPainter;
  final LinePainter linePainter;
  int scale = 1;

  PaintController({required this.polyPainter, required this.linePainter});

  List<Flaeche> flaechen = [];

  void drawPoint(Offset pos) {
    linePainter.addPoint(pos);
  }

  void tap(Offset pos) {
    if (!linePainter.isDrawing) {
      Flaeche? result;
      for (Flaeche flaeche in flaechen.reversed) {
        if (flaeche.path.contains(pos)) {
          result = flaeche;
          break;
        }
      }
      if (result != null) {
        flaechen.remove(result);
        linePainter.drawFinishedArea(result.area);
        polyPainter.drawFlaechen(flaechen);
      }
    }
  }

  void finishArea() {
    List<Offset> area = linePainter.finishArea();
    if (area.isNotEmpty) {
      flaechen.add(Flaeche(area: area));
      switch (flaechen.length) {
        case 1:
          flaechen.last.color = Colors.blue;
          break;
        case 2:
          flaechen.last.color = Colors.green;
          break;
        case 3:
          flaechen.last.color = Colors.red;
          break;
        case 4:
          flaechen.last.color = Colors.yellow;
          break;
        case 5:
          flaechen.last.color = Colors.white;
          break;
        case 6:
          flaechen.last.color = Colors.brown;
          break;
        case 7:
          flaechen.last.color = Colors.orange;
          break;
        case 8:
          flaechen.last.color = Colors.pink;
          break;
        case 9:
          flaechen.last.color = Colors.purple;
          break;
        case 10:
          flaechen.last.color = Colors.lightGreen;
          break;
      }
      polyPainter.drawFlaechen(flaechen);
    }
  }

  void undo() {
    linePainter.undo();
  }

  int updateScale() {
    return 1;
  }
}
