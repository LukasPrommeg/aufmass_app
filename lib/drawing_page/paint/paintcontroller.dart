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
  int indexOfFirstLaengenWerkstoff = 0;

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
      _wallCount = 0;
      linePainter.reset();
      polyPainter.reset();
      _drawingWerkstoff = false;
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
      _wallCount = 0;
      linePainter.reset();
      polyPainter.reset();
      _drawingWerkstoff = false;
      addWall(Wall.fromStart(angle: 0, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 90, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 180, length: 1000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(null);
    } else if (string.toLowerCase() == "testwohnzimmer") {
      _werkstoffe.clear();
      walls.clear();
      _wallCount = 0;
      linePainter.reset();
      polyPainter.reset();
      _drawingWerkstoff = false;
      addWall(Wall.fromStart(angle: 0, length: 6000, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 90, length: 4260, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 180, length: 2280, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 90, length: 6960, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 180, length: 1050, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 270, length: 4330, start: Corner.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Wall.fromStart(angle: 180, length: 2670, start: Corner.fromPoint(point: Offset.zero)));
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
      polyPainter.selectCorner = false;
      polyPainter.selectedCorner = null;
      _drawingWerkstoff = false;
      polyPainter.hiddenCorners.clear();
      switch (args.value) {
        case InputState.selectStartingpoint:
          polyPainter.selectCorner = true;
          break;
        case InputState.draw:
          _werkstoffPopup.calcStartingpointWithOffset();
          if (_werkstoffPopup.startingPoint != null) {
            _werkstoffPopup.startingPoint!.initScale(scalingData.scale, scalingData.center);
            if (_werkstoffPopup.werkStoffneedsmorePoints()) {
              _drawingWerkstoff = true;
              polyPainter.selectCorner = true;
              Corner? startPoly = grundFlaeche!.findCornerAtPoint(_werkstoffPopup.startingPoint!.point);
              if (startPoly != null) {
                polyPainter.hiddenCorners.add(startPoly);
              }
              linePainter.isDrawing = true;
              linePainter.selectedCorner = _werkstoffPopup.startingPoint;
            } else {
              finishWerkstoff();
            }
          } else {
            //TODO: Fehlermeldung, fehler beim Parsen
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
      if (wall.length == 0) {
        double length = grundFlaeche!.findMaxLength(_werkstoffPopup.startingPoint!, wall.angle);
        wall = Wall.fromStart(angle: wall.angle, length: length, start: Corner.fromPoint(point: Offset.zero));
      }
      if (walls.isEmpty) {
        _wallCount++;

        if (_drawingWerkstoff) {
          wall = Wall.fromStart(angle: wall.angle, length: wall.length, start: linePainter.selectedCorner!);
        }
        wall.id = _wallCount;

        walls.add(wall);
        updateDrawingState.broadcast();
      } else {
        if (linePainter.selectedCorner == null) {
          //TODO: Fehlermeldung, sollte aber nicht erreichbar sein
          return;
        } else {
          _wallCount++;

          if (linePainter.selectedCorner! == walls.first.start) {
            if (wall.angle <= 180) {
              wall = Wall.fromEnd(angle: wall.angle + 180, length: wall.length, end: walls.first.start);
            } else {
              wall = Wall.fromEnd(angle: wall.angle - 180, length: wall.length, end: walls.first.start);
            }
            wall.id = _wallCount;
            walls.insert(0, wall);
          } else if (linePainter.selectedCorner! == walls.last.end) {
            wall = Wall.fromStart(angle: wall.angle, length: wall.length, start: walls.last.end);
            wall.id = _wallCount;
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
      if (polyPainter.selectCorner && _werkstoffPopup.state == InputState.draw) {
        if (linePainter.selectedCorner == null) {
          linePainter.selectedCorner = linePainter.detectClickedCorner(position);
        } else {
          Corner? wallEnd = grundFlaeche?.detectClickedCorner(position);
          if (wallEnd != null && !polyPainter.hiddenCorners.contains(wallEnd)) {
            Offset diff = wallEnd.point - linePainter.selectedCorner!.point;
            double angle = (diff.direction * (180 / pi)) + 90;
            double length = sqrt(pow(diff.dx, 2) + pow(diff.dy, 2));
            Wall wall = Wall(angle: angle, length: length, start: linePainter.selectedCorner!, end: wallEnd);
            addWall(wall);
            polyPainter.hiddenCorners.add(wallEnd);
          } else {
            linePainter.selectedCorner = linePainter.detectClickedCorner(position);
          }
        }
      } else {
        linePainter.selectedCorner = linePainter.detectClickedCorner(position);
      }
    } else if (polyPainter.selectCorner && _werkstoffPopup.state == InputState.selectStartingpoint) {
      polyPainter.selectedCorner = grundFlaeche?.detectClickedCorner(position);
      if (polyPainter.selectedCorner != null) {
        _werkstoffPopup.startingPoint = polyPainter.selectedCorner!;
        List<Wall> around = grundFlaeche!.findWallsAroundCorner(polyPainter.selectedCorner!);
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
      _wallCount = 0;
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
    DrawedWerkstoff drawedWerkstoff = DrawedWerkstoff(clickAble: clickAble, werkstoff: werkstoff, hasBeschriftung: true);
    switch (werkstoff.typ) {
      //TODO: funktiert nicht
      case WerkstoffTyp.flaeche:
        if (indexOfFirstLaengenWerkstoff == 0) {
          _werkstoffe.insert(indexOfFirstLaengenWerkstoff, drawedWerkstoff);
        } else {
          _werkstoffe.insert(indexOfFirstLaengenWerkstoff - 1, drawedWerkstoff);
        }
        indexOfFirstLaengenWerkstoff++;
        break;
      case WerkstoffTyp.linie:
        _werkstoffe.insert(indexOfFirstLaengenWerkstoff, drawedWerkstoff);
        indexOfFirstLaengenWerkstoff++;
        break;
      case WerkstoffTyp.point:
        _werkstoffe.add(drawedWerkstoff);

        break;
      default:
        return;
    }
    _drawingWerkstoff = false;
    _werkstoffPopup.finish();
    polyPainter.selectCorner = false;
    polyPainter.hiddenCorners.clear();
    walls.clear();
    _wallCount = 0;
    linePainter.reset();
    updateDrawingState.broadcast();
  }

  void undo() {
    if (_wallCount > 1) {
      walls.removeWhere((wall) {
        if (wall.id == _wallCount) {
          polyPainter.hiddenCorners.removeWhere((element) => element.point == wall.end.point);
          return true;
        }
        return false;
      });
      _wallCount--;
    } else {
      walls.clear();
      _wallCount = 0;
      linePainter.reset();
      if (_drawingWerkstoff) {
        polyPainter.hiddenCorners.clear();
        _drawingWerkstoff = false;
        _werkstoffPopup.finish();
      }
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
    if (linePainter.selectedCorner != null) {
      linePainter.selectedCorner!.initScale(scalingData.scale, center);
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
        return _wallPopup.display(context, !_drawingWerkstoff);
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
        return _wallPopup.display(context, !_drawingWerkstoff);
      } else {
        //TODO: Fehlermeldung
      }
    } else {
      _werkstoffPopup.display(context);
    }
  }

  void roomFromJSON() {}
}
