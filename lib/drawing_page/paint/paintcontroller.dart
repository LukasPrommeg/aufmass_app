import 'dart:math';
import 'package:aufmass_app/Misc/clickable.dart';
import 'package:aufmass_app/PopUP/werkstoffinput.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:aufmass_app/drawing_page/paint/corner.dart';
import 'package:aufmass_app/drawing_page/paint/flaeche.dart';
import 'package:aufmass_app/drawing_page/paint/grundflaeche.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/Einheiten/einheitcontroller.dart';
import 'package:aufmass_app/PopUP/wallinputpopup.dart';
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

  //Popups
  final WallInputPopup _wallPopup = WallInputPopup();
  final WerkstoffInputPopup _werkstoffPopup = WerkstoffInputPopup();

  //Member
  ScalingData scalingData = ScalingData(scale: 1, rect: Rect.zero, center: Offset.zero);
  late Size? _canvasSize;
  List<Wall> walls = [];
  int _wallCount = 0;
  String _roomName = "";
  Grundflaeche? grundFlaeche;
  final List<DrawedWerkstoff> _werkstoffe = [];
  bool _drawingWerkstoff = false;

  //Events
  final updateScaleRectEvent = Event<ScalingData>();
  final updateDrawingState = Event();
  final clickedEvent = Event<EventArgs>();
  final clickedGrundEvent = Event<ClickAble>();

  PaintController() {
    polyPainter = PolyPainter(repaint: _repaint);
    linePainter = LinePainter(repaint: _repaint);
    _wallPopup.addWallEvent.subscribe((args) => addWall(args));
    _einheitController.updateEinheitEvent.subscribe((args) {
      repaint();
    });
    _werkstoffPopup.inputStateChangedEvent.subscribe((args) => handleWerkstoffInputState(args));
  }

  set roomName(String string) {
    _roomName = string;
    if (grundFlaeche != null) {
      grundFlaeche!.raumName = string;
    }
    if (string.toLowerCase() == "testpoly") {
      _werkstoffe.clear();
      walls.clear();
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

  void handleWerkstoffInputState(InputStateEventArgs? args) {
    if (args != null) {
      polyPainter.selectStartingpoint = false;
      polyPainter.selectedStartingpoint = null;
      _drawingWerkstoff = false;
      switch (args.value) {
        case InputState.selectStartingpoint:
          polyPainter.selectStartingpoint = true;
          break;
        case InputState.draw:
          if (_werkstoffPopup.werkStoffneedsmorePoints()) {
            Corner? startingPoint = _werkstoffPopup.calcStartingpointWithOffset();
            if (startingPoint != null) {
              _drawingWerkstoff = true;
              linePainter.startingPoint = _werkstoffPopup.startingPoint;
              startingPoint.initScale(scalingData.scale, scalingData.center);
            } else {
              //TODO: Fehlermeldung, fehler beim Parsen
            }
          }
          break;
        default:
          break;
      }
      repaint();
    }
  }

  void addWall(Wall? wall) {
    if (wall != null) {
      if (walls.isEmpty) {
        _wallCount++;

        wall.id = _wallCount;
        if (_drawingWerkstoff) {
          wall = Wall.fromStart(angle: wall.angle, length: wall.length, start: _werkstoffPopup.startingPoint!);
          linePainter.startingPoint = null;
        }
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
      if (_drawingWerkstoff) {
        _werkstoffPopup.amountOfDrawedPoints++;
        if (!_werkstoffPopup.werkStoffneedsmorePoints()) {
          finishWerkstoff();
        }
      }

      linePainter.selectedCorner = null;
    } else {
      if (_drawingWerkstoff) {
        finishWerkstoff();
      } else {
        finishArea();
      }
    }
    _updateScaleAndCenter();
  }

  void tap(Offset position) {
    if (linePainter.isDrawing) {
      linePainter.selectedCorner = linePainter.detectClickedCorner(position);
    } else if (polyPainter.selectStartingpoint) {
      polyPainter.selectedStartingpoint = grundFlaeche?.detectClickedCorner(position);
      if (polyPainter.selectedStartingpoint != null) {
        _werkstoffPopup.startingPoint = polyPainter.selectedStartingpoint!;
        List<Wall> around = grundFlaeche!.findWallsAroundCorner(polyPainter.selectedStartingpoint!);
        print(around.length);
        _werkstoffPopup.infront = Wall.fromStart(angle: around.first.angle, length: around.first.length, start: Corner.fromPoint(point: Offset.zero));
        _werkstoffPopup.behind = Wall.fromStart(angle: around.last.angle, length: around.last.length, start: _werkstoffPopup.infront!.end);
      } else {
        _werkstoffPopup.infront = null;
        _werkstoffPopup.startingPoint = null;
        _werkstoffPopup.behind = null;
      }
    } else {
      ClickAble? result = findClickedObject(position);

      if (result != null) {
        //TODO: EDIT
      } else {
        polyPainter.clickedWerkstoff = null;
      }
      clickedEvent.broadcast(result);
    }
    _updateScaleAndCenter();
    repaint();
  }

  ClickAble? findClickedObject(Offset position) {
    ClickAble? result;
    if (grundFlaeche != null) {
      result = grundFlaeche!.detectClickedWall(position);
      if (result != null) {
        return result;
      }
    }
    if (grundFlaeche != null) {
      if (grundFlaeche!.contains(position)) {
        return grundFlaeche;
      }
    }
    return result;
  }

  void finishArea() {
    if (linePainter.finishArea()) {
      grundFlaeche = Grundflaeche(raumName: _roomName, walls: List.from(walls));
      walls.clear();
      updateDrawingState.broadcast();
    }
  }

  void finishWerkstoff() {
    Werkstoff werkstoff = _werkstoffPopup.selectedWerkstoff!;
    ClickAble clickAble;
    switch (werkstoff.typ) {
      case WerkstoffTyp.flaeche:
        clickAble = Flaeche(walls: List.from(walls));
        break;
      case WerkstoffTyp.linie:
        clickAble = walls.first;
        break;
      case WerkstoffTyp.point:
        clickAble = _werkstoffPopup.startingPoint!;
        break;
      default:
        return;
    }
    DrawedWerkstoff drawedWerkstoff = DrawedWerkstoff(clickAble: clickAble, werkstoff: werkstoff, beschriftung: true);
    _werkstoffe.add(drawedWerkstoff);
    _drawingWerkstoff = false;
    _werkstoffPopup.finish();
    walls.clear();
    linePainter.reset();
    updateDrawingState.broadcast();
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
      for (DrawedWerkstoff werkstoff in _werkstoffe) {
        newRect = newRect.expandToInclude(werkstoff.clickAble.size);
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
    for (DrawedWerkstoff werkstoff in _werkstoffe) {
      werkstoff.clickAble.initScale(scalingData.scale, center);
    }
    if (linePainter.startingPoint != null) {
      linePainter.startingPoint!.initScale(scalingData.scale, center);
    }

    linePainter.drawWalls(walls);
    polyPainter.drawGrundflaeche(grundFlaeche);
    polyPainter.drawWerkstoffe(_werkstoffe);
    repaint();
  }

  Future<void> displayDialog(BuildContext context) async {
    if (grundFlaeche == null || _drawingWerkstoff) {
      if (walls.isEmpty) {
        _wallPopup.init(0, true);
        return _wallPopup.display(context);
      } else if (linePainter.selectedCorner != null) {
        if (linePainter.selectedCorner! == walls.first.start) {
          if (walls.first.angle <= 180) {
            _wallPopup.init(walls.first.angle + 180, false);
          } else {
            _wallPopup.init(walls.first.angle - 180, false);
          }
        } else if (linePainter.selectedCorner! == walls.last.end) {
          _wallPopup.init(walls.last.angle, false);
        }
        return _wallPopup.display(context);
      } else {
        //TODO: Fehlermeldung
      }
    } else {
      _werkstoffPopup.display(context);
    }
  }

  void roomFromJSON() {}
}
