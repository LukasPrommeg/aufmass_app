import 'dart:math';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/Misc/einheitcontroller.dart';
import 'package:flutter_test_diplom/drawing_page/paint/corner.dart';
import 'package:flutter_test_diplom/drawing_page/paint/flaeche.dart';
import 'package:flutter_test_diplom/PopUP/inputpopup.dart';
import 'package:flutter_test_diplom/drawing_page/paint/linepainter.dart';
import 'package:flutter_test_diplom/drawing_page/paint/polypainter.dart';
import 'package:flutter_test_diplom/drawing_page/paint/wall.dart';

class Scale extends EventArgs {
  final double value;

  Scale({required this.value});
}

class PaintController {
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);

  //Painter
  late PolyPainter polyPainter;
  late LinePainter linePainter;

  //Controller
  final EinheitController _einheitController = EinheitController();
  final InputPopup _inputPopup = InputPopup();

  //Member
  Scale scale = Scale(value: 1);
  final List<Flaeche> _flaechen = [];
  late Size? _canvasSize;
  List<Wall> walls = [];
  Rect drawingRect = Rect.zero;

  //Events
  final updateScaleEvent = Event<Scale>();
  final updateDrawingState = Event();

  PaintController() {
    polyPainter = PolyPainter(repaint: _repaint);
    linePainter = LinePainter(repaint: _repaint);
    _inputPopup.addWallEvent.subscribe((args) => addWall(args));
    _einheitController.updateEinheitEvent.subscribe((args) {
      repaint();
    });
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
      if (walls.isEmpty) {
        walls.add(wall);
        updateDrawingState.broadcast();
      } else {
        if (linePainter.selectedCorner == null) {
          //TODO: Fehlermeldung, sollte aber nicht erreichbar sein
          return;
        } else if (linePainter.selectedCorner!.center ==
            walls.first.scaledStart!.center) {
          if (wall.angle <= 180) {
            wall = Wall(angle: wall.angle + 180, length: wall.length);
          } else {
            wall = Wall(angle: wall.angle - 180, length: wall.length);
          }
          //wall.end *= -1;
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
    if (area.isNotEmpty) {
      Offset center = drawingRect.center;
      center = (center * scale.value) - _canvasSize!.center(Offset.zero);
      _flaechen.add(
          Flaeche(walls: List.from(walls), scale: scale.value, center: center));
      walls.clear();
      polyPainter.drawFlaechen(_flaechen);
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
      drawingRect = Rect.zero;
      for (Wall wall in walls) {
        origin += wall.end;
        drawingRect =
            drawingRect.expandToInclude(Rect.fromPoints(origin, origin));
      }
      for (Flaeche flaeche in _flaechen) {
        drawingRect = drawingRect.expandToInclude(flaeche.size);
      }

      double maxScaleX = _canvasSize!.width / drawingRect.size.width.abs();
      double maxScaleY = _canvasSize!.height / drawingRect.size.height.abs();
      scale = Scale(value: min(maxScaleX, maxScaleY) * 0.8);

      updateScaleEvent.broadcast(scale);

      Offset center = drawingRect.center;

      center = (center * scale.value) - _canvasSize!.center(Offset.zero);

      _drawWallsWithScale(center);
    } else {
      //TODO: Fehler beim setzen von _canvasSize, sollte nicht möglich sein
    }
  }

  void _drawWallsWithScale(Offset center) {
    Offset origin = Offset.zero - center;

    for (Wall wall in walls) {
      wall.scaledStart = Corner(center: origin);
      origin += (wall.end * scale.value);
      wall.scaledEnd = Corner(center: origin);
    }
    for (Flaeche flaeche in _flaechen) {
      flaeche.init(scale.value, center);
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
