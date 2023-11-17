import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/flaeche.dart';
import 'package:flutter_test_diplom/paint/addpopupcontroller.dart';
import 'package:flutter_test_diplom/paint/linepainter.dart';
import 'package:flutter_test_diplom/paint/polypainter.dart';

class PaintController {
  final PolyPainter polyPainter;
  final LinePainter linePainter;
  final AddPopUpController popUpController = AddPopUpController();
  Listenable repaint;
  double scale = 1;
  Offset? drawFromPoint;

  PaintController(
      {required this.polyPainter,
      required this.linePainter,
      required this.repaint}) {
    polyPainter.scale = 1;
  }

  List<Flaeche> flaechen = [];

  void drawPoint(Offset pos) {
    drawfinishedArea(linePainter.drawPoint(pos));
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
        linePainter.drawFinishedArea(result.corners);
        polyPainter.drawFlaechen(flaechen);
      }
    }
  }

  void finishArea() {
    List<Offset> area = linePainter.finishArea();
    drawfinishedArea(area);
  }

  void drawfinishedArea(List<Offset>? area) {
    if (area != null && area.isNotEmpty) {
      flaechen.add(Flaeche(corners: area));
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

  Future<void> displayTextInputDialog(BuildContext context) async {
    return popUpController.displayTextInputDialog(context);
  }

  void roomFromJSON() {}
}
