import 'dart:math';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/corner.dart';
import 'package:flutter_test_diplom/drawing_page/paint/flaeche.dart';
import 'package:flutter_test_diplom/PopUP/inputpopup.dart';
import 'package:flutter_test_diplom/drawing_page/paint/linepainter.dart';
import 'package:flutter_test_diplom/drawing_page/paint/polypainter.dart';
import 'package:flutter_test_diplom/drawing_page/paint/wall.dart';

enum Einheit { mm, cm, m }

class PaintController {
  static final PaintController _instance = PaintController._internal();

  late PolyPainter polyPainter;
  late LinePainter linePainter;
  final InputPopup _inputPopup = InputPopup();
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);
  double scale = 1;
  final List<Flaeche> _flaechen = [];
  late Size? _canvasSize;
  List<Wall> walls = [];
  
  
  Set<Einheit> _einheitSelection = <Einheit>{Einheit.mm};
  Einheit get selectedEinheit{
    return _einheitSelection.first;
  }
  set selectedEinheit (Einheit newSel){
    _einheitSelection = {newSel};
    repaint();
  }


  final updateDrawingState = Event();

  Rect drawingRect = Rect.zero;

  factory PaintController() {
    return _instance;
  }

  PaintController._internal() {
    polyPainter = PolyPainter(repaint: _repaint);
    linePainter = LinePainter(repaint: _repaint);
    _inputPopup.addWallEvent.subscribe((args) => addWall(args));
  }

  set canvasSize(Size size) {
    _canvasSize = size;
    _updateScaleAndCenter();
  }

  bool get isDrawing {
    return walls.isNotEmpty;
  }

  void repaint() {
    _repaint.value++;
  }

  void addWall(Wall? wall) {
    if (wall != null) {
      wall = convertToMM(wall);

      if (walls.isEmpty) {
        walls.add(wall);
        updateDrawingState.broadcast();
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
      linePainter.selectedCorner = null;
    } else {
      finishArea();
      updateDrawingState.broadcast();
    }
    _updateScaleAndCenter();
  }

  Wall convertToMM(Wall wall) {
    switch (selectedEinheit) {
      case Einheit.cm:
        wall = Wall(angle: wall.angle, length: wall.length * 10);
        break;
      case Einheit.m:
        wall = Wall(angle: wall.angle, length: wall.length * 1000);
        break;
      default:
        break;
    }
    return wall;
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
    if (area != null && area.isNotEmpty) {

      double length = sqrt((pow(walls.last.end.dx, 2) + pow(walls.last.end.dy, 2)));

      //Offset direction = Offset.
      double angle = atan(walls.last.end.dy / walls.last.end.dx); //* 180 / pi;

      print(length);
      print(angle);

      Wall last = Wall(angle: angle, length: length);

      Offset center = drawingRect.center;
      center = (center * scale) - _canvasSize!.center(Offset.zero);
      _flaechen
          .add(Flaeche(walls: List.from(walls), scale: scale, center: center));
      polyPainter.drawFlaechen(_flaechen);
      walls.clear();
    }
    repaint();
  }

  void undo() {
    linePainter.undo();
    repaint();
  }

  void _updateScaleAndCenter() {
    if (_canvasSize != null) {
      Offset origin = Offset.zero;
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
    for (Flaeche flaeche in _flaechen) {
      flaeche.init(scale, center);
    }
    linePainter.drawWalls(walls);
    repaint();
  }

  Future<void> displayTextInputDialog(BuildContext context) async {
    if (walls.isEmpty) {
      _inputPopup.init(0, true);
      return _inputPopup.displayTextInputDialog(context);
    } else if (linePainter.selectedCorner != null) {
      if (linePainter.selectedCorner!.center ==
          walls.first.scaledStart!.center) {
        if (walls.first.angle <= 180) {
          _inputPopup.init(walls.first.angle + 180, false);
        } else {
          _inputPopup.init(walls.first.angle - 180, false);
        }
      } else if (linePainter.selectedCorner!.center ==
          walls.last.scaledEnd!.center) {
        _inputPopup.init(walls.last.angle, false);
      }
      return _inputPopup.displayTextInputDialog(context);
    } else {
      //TODO: Fehlermeldung
    }
  }

  void roomFromJSON() {}
}
