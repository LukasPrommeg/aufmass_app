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
    _popUpController.addWallEvent.subscribe((args) => addWall(args));
  }

  set canvasSize(Size size) {
    _canvasSize = size;

    if (walls.isEmpty) {
      addWall(Wall(angle: 0, length: 2));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 90, length: 3));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 180, length: 2));
      linePainter.selectedCorner = walls.last.scaledEnd;
      /*addWall(Wall(angle: 270, length: 1));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 180, length: 1));
      linePainter.selectedCorner = walls.last.scaledEnd;*/
      //addWall(Wall(angle: 180, length: 1));
    }
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
        //TODO: EDIT
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
      Offset center = drawingRect.center;
      center = (center * scale) - _canvasSize!.center(Offset.zero);
      _flaechen.add(Flaeche(walls: walls, scale: scale, center: center));
      polyPainter.drawFlaechen(_flaechen);
      walls.clear();
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
