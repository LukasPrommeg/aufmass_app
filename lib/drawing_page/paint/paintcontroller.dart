import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/corner.dart';
import 'package:flutter_test_diplom/drawing_page/paint/flaeche.dart';
import 'package:flutter_test_diplom/drawing_page/paint/addpopupcontroller.dart';
import 'package:flutter_test_diplom/drawing_page/paint/linepainter.dart';
import 'package:flutter_test_diplom/drawing_page/paint/polypainter.dart';
import 'package:flutter_test_diplom/drawing_page/paint/wall.dart';

class PaintController {
  late PolyPainter polyPainter;
  late LinePainter linePainter;
  final AddPopUpController _popUpController = AddPopUpController();
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);
  double scale = 1;
  final List<Flaeche> _flaechen = [];
  late Size? _canvasSize;
  List<Wall> walls = [];

  Rect drawingRect = Rect.zero;

  PaintController() {
    polyPainter = PolyPainter(repaint: _repaint);
    linePainter = LinePainter(repaint: _repaint);
    polyPainter.scale = 1;
    _popUpController.addWallEvent.subscribe((args) => addWall(args));
  }

  set canvasSize(Size size) {
    _canvasSize = size;
  }

  void repaint() {
    _repaint.value++;
  }

  void drawPoint(Offset pos) {
    //_drawfinishedArea(linePainter.drawPoint(pos));
    repaint();
  }

  void addWall(Wall? wall) {
    if (wall != null) {
      if (walls.isEmpty) {
        walls.add(wall);
      } else {
        if (linePainter.selectedCorner == null) {
          //TODO: Fehlermeldung, sollte aber nicht erreichbar sein
          return;
        } else if (linePainter.selectedCorner!.center ==
            walls.first.scaledStart!.center) {
          walls.insert(0, wall);
        } else if (linePainter.selectedCorner!.center ==
            walls.last.scaledEnd!.center) {
          walls.add(wall);
        }
      }
      _updateScaleAndCenter();
      linePainter.selectedCorner = null;
    } else {
      finishArea();
    }
  }

  void setPositionsAroundCenter(Offset center) {
    if (walls.isEmpty) {
      return;
    }

    for (Wall wall in walls) {
      Offset start = wall.scaledStart!.center - center;
      Offset end = wall.scaledEnd!.center - center;

      wall.scaledStart = Corner(center: start);
      wall.scaledEnd = Corner(center: end);
    }
  }

  void tap(Offset pos) {
    if (linePainter.isDrawing) {
      linePainter.selectedCorner = linePainter.detectClickedCorner(pos);
    } else {
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

  void _updateScaleAndCenter() {
    if (_canvasSize != null) {
      Offset origin = Offset.zero;
      drawingRect = Rect.fromCenter(center: origin, width: 0, height: 0);
      for (Wall wall in walls) {
        if (!drawingRect.contains(origin + wall.end)) {
          drawingRect = drawingRect.expandToInclude(
              Rect.fromPoints(origin + wall.end, origin + wall.end));
        }
        origin += wall.end;
      }

      linePainter.testRect =
          drawingRect.shift(_canvasSize!.center(Offset.zero));

      double maxScaleX = _canvasSize!.width / drawingRect.size.width.abs();
      double maxScaleY = _canvasSize!.height / drawingRect.size.height.abs();
      scale = min(maxScaleX, maxScaleY) * 0.8;

      Offset center = drawingRect.center;

      linePainter.testCenter = center + _canvasSize!.center(Offset.zero);
      center = (center * scale) - _canvasSize!.center(Offset.zero);

      _drawWallsWithScale(center);
    } else {
      //TODO: Fehler beim setzen von _canvasSize, sollte nicht möglich sein
    }
  }

  void _drawWallsWithScale(Offset center) {
    Offset origin = Offset.zero - center;

    for (Wall wall in walls) {
      wall.scaledStart = Corner(center: origin);
      origin += (wall.end * scale);
      wall.scaledEnd = Corner(center: origin);
    }
    linePainter.drawWalls(walls);
    repaint();
  }

  Future<void> displayTextInputDialog(BuildContext context) async {
    if (walls.isEmpty) {
      _popUpController.init(0, true);
      return _popUpController.displayTextInputDialog(context);
    } else if (linePainter.selectedCorner != null) {
      if (linePainter.selectedCorner!.center ==
          walls.first.scaledStart!.center) {
        if (walls.first.angle <= 180) {
          _popUpController.init(walls.first.angle + 180, false);
        } else {
          _popUpController.init(walls.first.angle - 180, false);
        }
      } else if (linePainter.selectedCorner!.center ==
          walls.last.scaledEnd!.center) {
        _popUpController.init(walls.last.angle, false);
      }
      return _popUpController.displayTextInputDialog(context);
    } else {
      //TODO: Fehlermeldung
    }
  }

  void roomFromJSON() {}
}
