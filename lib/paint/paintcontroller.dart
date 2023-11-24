import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/flaeche.dart';
import 'package:flutter_test_diplom/paint/addpopupcontroller.dart';
import 'package:flutter_test_diplom/paint/linepainter.dart';
import 'package:flutter_test_diplom/paint/polypainter.dart';
import 'package:flutter_test_diplom/paint/wall.dart';

class PaintController {
  late PolyPainter polyPainter;
  late LinePainter linePainter;
  final AddPopUpController _popUpController = AddPopUpController();
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);
  double scale = 1;
  List<Flaeche> _flaechen = [];
  Wall? first;
  

  PaintController() {
    polyPainter = PolyPainter(repaint: _repaint);
    linePainter = LinePainter(repaint: _repaint);
    polyPainter.scale = 1;
    _popUpController.addWallEvent.subscribe((args) => addWall(args));
  }

  void repaint () {
    _repaint.value++;
  }

  void drawPoint(Offset pos) {
    _drawfinishedArea(linePainter.drawPoint(pos));
    repaint();
  }

  void addWall(Wall? wall) {
    if (wall != null) {
      if(first == null) {
        first = wall;
      }
      else {

      }
    }
    else {
      finishArea();
    }
    repaint();
  }

  void tap(Offset pos) {
    if (!linePainter.isDrawing) {
      Flaeche? result;
      for (Flaeche flaeche in _flaechen.reversed) {
        if (flaeche.path.contains(pos)) {
          result = flaeche;
          break;
        }
      }
      if (result != null) {
        _flaechen.remove(result);
        linePainter.drawFinishedArea(result.corners);
        polyPainter.drawFlaechen(_flaechen);
      }
    }
    repaint();    
  }

  void finishArea() {
    List<Offset> area = linePainter.finishArea();
    _drawfinishedArea(area);
    repaint();
  }

  void _drawfinishedArea(List<Offset>? area) {
    if (area != null && area.isNotEmpty) {
      _flaechen.add(Flaeche(corners: area));
      switch (_flaechen.length) {
        case 1:
          _flaechen.last.color = Colors.blue;
          break;
        case 2:
          _flaechen.last.color = Colors.green;
          break;
        case 3:
          _flaechen.last.color = Colors.red;
          break;
        case 4:
          _flaechen.last.color = Colors.yellow;
          break;
        case 5:
          _flaechen.last.color = Colors.white;
          break;
        case 6:
          _flaechen.last.color = Colors.brown;
          break;
        case 7:
          _flaechen.last.color = Colors.orange;
          break;
        case 8:
          _flaechen.last.color = Colors.pink;
          break;
        case 9:
          _flaechen.last.color = Colors.purple;
          break;
        case 10:
          _flaechen.last.color = Colors.lightGreen;
          break;
      }
      polyPainter.drawFlaechen(_flaechen);
    }
  }

  void undo() {
    linePainter.undo();
    repaint();
  }

  int _updateScale() {
    repaint();
    return 1;
  }

  Future<void> displayTextInputDialog(BuildContext context) async {
    //popUpController.init(lastWallAngle, isFirstWall);
    return _popUpController.displayTextInputDialog(context);
  }

  void roomFromJSON() {}
}
