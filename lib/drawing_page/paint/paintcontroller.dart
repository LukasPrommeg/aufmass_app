import 'dart:math';
import 'package:aufmass_app/Misc/hitbox.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/Misc/einheitcontroller.dart';
import 'package:aufmass_app/drawing_page/paint/corner.dart';
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

  //Events
  final updateScaleRectEvent = Event<ScalingData>();
  final updateDrawingState = Event();
  final clickedEvent = Event<EventArgs>();

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
    if (_flaechen.isNotEmpty) {
      _flaechen.first.name = string;
    }
    if (string.toLowerCase() == "testpoly") {
      _flaechen.clear();
      walls.clear();
      addWall(Wall(angle: 0, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 30, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 60, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 90, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 120, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 150, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 180, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 210, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 240, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 270, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 300, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(null);
    } else if (string.toLowerCase() == "testquad") {
      _flaechen.clear();
      walls.clear();
      addWall(Wall(angle: 0, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 90, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
      addWall(Wall(angle: 180, length: 1000));
      linePainter.selectedCorner = walls.last.scaledEnd;
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
          if (linePainter.selectedCorner!.center == walls.first.scaledStart!.center) {
            if (wall.angle <= 180) {
              wall = Wall(angle: wall.angle + 180, length: wall.length);
            } else {
              wall = Wall(angle: wall.angle - 180, length: wall.length);
            }
            walls.insert(0, wall);
          } else if (linePainter.selectedCorner!.center == walls.last.scaledEnd!.center) {
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
      EventArgs? result;

      for (Flaeche flaeche in _flaechen) {
        ClickAble? clicked = flaeche.findClickedPart(pos);
        if (clicked != null) {
          result = clicked;
          polyPainter.clicked = clicked;
          break;
        }
      }
      if (result == null) {
        for (Flaeche flaeche in _flaechen.reversed) {
          if (flaeche.path.contains(pos)) {
            polyPainter.clicked = null;
            result = flaeche;
            break;
          }
        }
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
    List<Offset> area = linePainter.finishArea();
    if (area.isNotEmpty) {
      Offset center = scalingData.rect.center;
      center = (center * scalingData.scale) - _canvasSize!.center(Offset.zero);
      Flaeche flaeche = Flaeche(walls: List.from(walls), scale: scalingData.scale, center: center);
      flaeche.name = _roomName;
      _flaechen.add(flaeche);
      walls.clear();
      polyPainter.drawFlaechen(_flaechen);
      updateDrawingState.broadcast();
    }
    repaint();
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
      Offset origin = Offset.zero;
      Rect newRect = Rect.zero;
      for (Wall wall in walls) {
        origin += wall.end;
        newRect = newRect.expandToInclude(Rect.fromPoints(origin, origin));
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

      _drawWallsWithScale(center);
    } else {
      //TODO: Fehler beim setzen von _canvasSize, sollte nicht möglich sein
    }
  }

  void _drawWallsWithScale(Offset center) {
    Offset origin = Offset.zero - center;

    for (Wall wall in walls) {
      wall.scaledStart = Corner(center: origin);
      origin += (wall.end * scalingData.scale);
      wall.scaledEnd = Corner(center: origin);
    }
    for (Flaeche flaeche in _flaechen) {
      flaeche.init(scalingData.scale, center);
    }
    linePainter.drawWalls(walls);
    repaint();
  }

  Future<void> displayTextInputDialog(BuildContext context) async {
    if (walls.isEmpty) {
      _inputPopup.init(0, true);
      return _inputPopup.displayTextInputDialog(context);
    } else if (linePainter.selectedCorner != null) {
      if (linePainter.selectedCorner!.center == walls.first.scaledStart!.center) {
        if (walls.first.angle <= 180) {
          _inputPopup.init(walls.first.angle + 180, false);
        } else {
          _inputPopup.init(walls.first.angle - 180, false);
        }
      } else if (linePainter.selectedCorner!.center == walls.last.scaledEnd!.center) {
        _inputPopup.init(walls.last.angle, false);
      }
      return _inputPopup.displayTextInputDialog(context);
    } else {
      //TODO: Fehlermeldung
    }
  }

  void roomFromJSON() {}
}
