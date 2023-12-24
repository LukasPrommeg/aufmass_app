import 'dart:math';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/drawing_page/paint/corner.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/Misc/einheitcontroller.dart';
import 'package:aufmass_app/drawing_page/paint/flaeche.dart';
import 'package:aufmass_app/PopUP/inputpopup.dart';
import 'package:aufmass_app/drawing_page/paint/linepainter.dart';
import 'package:aufmass_app/drawing_page/paint/polypainter.dart';
import 'package:aufmass_app/drawing_page/paint/wall.dart';

class ScalingData extends EventArgs {
  final double scale;
  final Rect rect;
  final Offset center;

  ScalingData({required this.scale, required this.rect, required this.center});
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
  ScalingData scalingData = ScalingData(scale: 1, rect: Rect.zero, center: Offset.zero);
  final List<Flaeche> _flaechen = [];
  late Size? _canvasSize;
  List<Wall> walls = [];
  int _wallCount = 0;
  String _roomName = "";
  Flaeche? grundFlaeche;
  final List<DrawedWerkstoff> _werkstoffe = [];

  //Events
  final updateScaleRectEvent = Event<ScalingData>();
  final updateDrawingState = Event();
  final clickedEvent = Event<DrawedWerkstoff>();

  PaintController() {
    polyPainter = PolyPainter(repaint: _repaint);
    linePainter = LinePainter(repaint: _repaint);
    _inputPopup.addWallEvent.subscribe((args) => addWall(args));
    _einheitController.updateEinheitEvent.subscribe((args) {
      repaint();
    });
  }

  set roomName(String string) {
    _roomName = string;
    if (grundFlaeche != null) {
      grundFlaeche!.name = string;
    }
    if (string.toLowerCase() == "testpoly") {
      _werkstoffe.clear();
      walls.clear();
      _flaechen.clear();
      addWall(Wall.fromStart(angle: 0, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 30, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 60, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 90, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 120, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 150, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 180, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 210, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 240, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 270, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 300, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(null);
    } else if (string.toLowerCase() == "testquad") {
      _werkstoffe.clear();
      walls.clear();
      _flaechen.clear();
      addWall(Wall.fromStart(angle: 0, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 90, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 180, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(null);
    }
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
        _wallCount++;

        wall.id = _wallCount;
        walls.add(wall);
        updateDrawingState.broadcast();
      } else {
        if (linePainter.selectedCorner == null) {
          //TODO: Fehlermeldung, sollte aber nicht erreichbar sein
          return;
        } else {
          _wallCount++;

          wall.id = _wallCount;
          if (linePainter.selectedCorner! == walls.first.start) {
            if (wall.angle <= 180) {
              wall = Wall.fromEnd(angle: wall.angle + 180, length: wall.length, end: walls.first.start);
            } else {
              wall = Wall.fromEnd(angle: wall.angle - 180, length: wall.length, end: walls.first.start);
            }
            walls.insert(0, wall);
          } else if (linePainter.selectedCorner! == walls.last.end) {
            wall = Wall.fromStart(angle: wall.angle, length: wall.length, start: walls.last.end);
            walls.add(wall);
          }
        }
      }
      linePainter.selectedCorner = null;
    } else {
      finishArea();
    }
    _updateScaleAndCenter();
  }

  void tap(Offset pos) {
    if (linePainter.isDrawing) {
      linePainter.selectedCorner = linePainter.detectClickedCorner(pos);
    } else {
      DrawedWerkstoff? result;

      //TODO: Anpassen

      for (DrawedWerkstoff werkstoff in _werkstoffe) {
        if (werkstoff.clickAble.contains(pos)) {
          result = werkstoff;
          polyPainter.clicked = werkstoff;
          break;
        }
      }
      if (result == null) {
        /*for (Flaeche flaeche in _flaechen.reversed) {
          if (flaeche.path.contains(pos)) {
            polyPainter.clicked = null;
            result = flaeche;
            break;
          }
        }*/
      }
      if (result != null) {
        //TODO: EDIT
      } else {
        polyPainter.clicked = null;
      }
      clickedEvent.broadcast(result);
    }
    _updateScaleAndCenter();
    repaint();
  }

  void finishArea() {
    if (linePainter.finishArea()) {
      Offset center = scalingData.rect.center;
      center = (center * scalingData.scale) - _canvasSize!.center(Offset.zero);
      Flaeche flaeche = Flaeche(walls: List.from(walls));
      flaeche.name = _roomName;
      if (grundFlaeche == null) {
        grundFlaeche = flaeche;
      } else {
        _flaechen.add(flaeche);
      }
      walls.clear();
      updateDrawingState.broadcast();
    }
  }

  void undo() {
    if (_wallCount > 1) {
      walls.removeWhere((element) => element.id == _wallCount);
      _wallCount--;
    } else {
      walls.clear();
      _wallCount = 0;
      updateDrawingState.broadcast();
    }
    _updateScaleAndCenter();
    repaint();
  }

  void _updateScaleAndCenter() {
    if (_canvasSize != null) {
      Rect newRect = Rect.zero;
      for (Wall wall in walls) {
        newRect = newRect.expandToInclude(Rect.fromPoints(wall.end.point, wall.end.point));
      }
      if (grundFlaeche != null) {
        newRect = newRect.expandToInclude(grundFlaeche!.size);
      }
      for (Flaeche flaeche in _flaechen) {
        newRect = newRect.expandToInclude(flaeche.size);
      }

      double maxScaleX = _canvasSize!.width / newRect.size.width.abs();
      double maxScaleY = _canvasSize!.height / newRect.size.height.abs();

      double scale = min(maxScaleX, maxScaleY) * 0.8;

      Offset center = newRect.center;

      center = (center * scale) - _canvasSize!.center(Offset.zero);

      scalingData = ScalingData(scale: scale, rect: newRect, center: center);

      updateScaleRectEvent.broadcast(scalingData);

      _drawWithScale(center);
    } else {
      //TODO: Fehler beim setzen von _canvasSize, sollte nicht möglich sein
    }
  }

  void _drawWithScale(Offset center) {
    for (Wall wall in walls) {
      wall.initScale(scalingData.scale, center);
    }
    if (grundFlaeche != null) {
      grundFlaeche!.initScale(scalingData.scale, center);
    }
    for (Flaeche flaeche in _flaechen) {
      flaeche.initScale(scalingData.scale, center);
    }
    linePainter.drawWalls(walls);
    polyPainter.drawFlaechen(_flaechen, grundFlaeche);
    repaint();
  }

  Future<void> displayTextInputDialog(BuildContext context) async {
    if (walls.isEmpty) {
      _inputPopup.init(0, true);
      return _inputPopup.displayTextInputDialog(context);
    } else if (linePainter.selectedCorner != null) {
      if (linePainter.selectedCorner! == walls.first.start) {
        if (walls.first.angle <= 180) {
          _inputPopup.init(walls.first.angle + 180, false);
        } else {
          _inputPopup.init(walls.first.angle - 180, false);
        }
      } else if (linePainter.selectedCorner! == walls.last.end) {
        _inputPopup.init(walls.last.angle, false);
      }
      return _inputPopup.displayTextInputDialog(context);
    } else {
      //TODO: Fehlermeldung
    }
  }

  void roomFromJSON() {}
}
