import 'dart:math';
import 'package:aufmass_app/PlanPage/Misc/alertinfo.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/clickable.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/einkerbung.dart';
import 'package:aufmass_app/PlanPage/Misc/input_utils.dart';
import 'package:aufmass_app/PlanPage/Misc/loadingblur.dart';
import 'package:aufmass_app/PlanPage/Misc/overlap.dart';
import 'package:aufmass_app/PlanPage/PopUP/ausnahmepopup.dart';
import 'package:aufmass_app/PlanPage/PopUP/selectactionpopup.dart';
import 'package:aufmass_app/PlanPage/PopUP/werkstoffinput.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/flaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/grundflaeche.dart';
import 'package:collection/collection.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitcontroller.dart';
import 'package:aufmass_app/PlanPage/PopUP/wallinputpopup.dart';
import 'package:aufmass_app/PlanPage/Paint/linepainter.dart';
import 'package:aufmass_app/PlanPage/Paint/polypainter.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/linie.dart';

class ScalingData extends EventArgs {
  final double scale;
  final Rect rect;
  final Offset center;
  final Size? canvasSize;

  ScalingData({required this.scale, required this.rect, required this.center, required this.canvasSize});
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
  final SelectActionPopup _selectActionPopup = SelectActionPopup();
  final WerkstoffInputPopup _werkstoffPopup = WerkstoffInputPopup();
  final AusnahmePopup _ausnahmePopup = AusnahmePopup();

  //Member
  ScalingData scalingData = ScalingData(scale: 1, rect: Rect.zero, center: Offset.zero, canvasSize: null);
  List<Linie> walls = [];
  int _wallCount = 0;
  String _flaechenName = "";
  Grundflaeche? grundFlaeche;
  bool _drawingWerkstoff = false;
  bool _drawingAusnahme = false;

  //Events
  final updateScaleRectEvent = Event<ScalingData>();
  final updateDrawingState = Event();
  final clickedEvent = Event<EventArgs>();
  final clickedGrundEvent = Event<ClickAble>();

  PaintController() {
    polyPainter = PolyPainter(repaint: _repaint);
    linePainter = LinePainter(repaint: _repaint);
    _wallPopup.addWallEvent.subscribe((args) async {
      LoadingBlur().enableBlur();
      addWall(args).then((value) => LoadingBlur().disableBlur());
    });
    _einheitController.updateEinheitEvent.subscribe((args) => repaint());
    _selectActionPopup.selectEvent.subscribe((args) {
      if (args != null) {
        displayDialog(args.context);
      }
    });
    _werkstoffPopup.inputStateChangedEvent.subscribe((args) => handleWerkstoffInputState(args));
    _ausnahmePopup.inputStateChangedEvent.subscribe((args) => handleEinkerbungInput(args));
  }

  set flaechenName(String string) {
    _flaechenName = string;
    if (grundFlaeche != null) {
      grundFlaeche!.raumName = string;
    }
    if (string.toLowerCase() == "testpoly") {
      grundFlaeche = null;
      reset();
      addWall(Linie.fromStart(angle: 0, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Linie.fromStart(angle: 30, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Linie.fromStart(angle: 60, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Linie.fromStart(angle: 90, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Linie.fromStart(angle: 120, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Linie.fromStart(angle: 150, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Linie.fromStart(angle: 180, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Linie.fromStart(angle: 210, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Linie.fromStart(angle: 240, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Linie.fromStart(angle: 270, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Linie.fromStart(angle: 300, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(null);
    } else if (string.toLowerCase() == "testquad") {
      grundFlaeche = null;
      reset();
      addWall(Linie.fromStart(angle: 0, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Linie.fromStart(angle: 90, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(Linie.fromStart(angle: 180, length: 1000, start: Punkt.fromPoint(point: Offset.zero)));
      linePainter.selectedCorner = walls.last.end;
      addWall(null);
    } else if (string.toLowerCase() == "testwohnzimmer") {
      grundFlaeche = null;
      reset();
      setupWohnzimmer();
    }
  }

  set canvasSize(Size size) {
    scalingData = ScalingData(scale: scalingData.scale, rect: scalingData.rect, center: scalingData.center, canvasSize: size);
    _updateScaleAndCenter();
  }

  bool get isDrawing {
    return walls.isNotEmpty;
  }

  Future<void> setupWohnzimmer() async {
    addWall(Linie.fromStart(angle: 0, length: 6000, start: Punkt.fromPoint(point: Offset.zero)));
    linePainter.selectedCorner = walls.last.end;
    addWall(Linie.fromStart(angle: 90, length: 4260, start: Punkt.fromPoint(point: Offset.zero)));
    linePainter.selectedCorner = walls.last.end;
    addWall(Linie.fromStart(angle: 180, length: 2280, start: Punkt.fromPoint(point: Offset.zero)));
    linePainter.selectedCorner = walls.last.end;
    addWall(Linie.fromStart(angle: 90, length: 6960, start: Punkt.fromPoint(point: Offset.zero)));
    linePainter.selectedCorner = walls.last.end;
    addWall(Linie.fromStart(angle: 180, length: 1050, start: Punkt.fromPoint(point: Offset.zero)));
    linePainter.selectedCorner = walls.last.end;
    addWall(Linie.fromStart(angle: 270, length: 4330, start: Punkt.fromPoint(point: Offset.zero)));
    linePainter.selectedCorner = walls.last.end;
    addWall(Linie.fromStart(angle: 180, length: 2670, start: Punkt.fromPoint(point: Offset.zero)));
    linePainter.selectedCorner = walls.last.end;
    addWall(null);

    _ausnahmePopup.startingPoint = grundFlaeche!.walls[5].end;
    _ausnahmePopup.tiefe = 100;
    _ausnahmePopup.name = "Podest";
    _drawingAusnahme = true;
    linePainter.isDrawing = true;
    _ausnahmePopup.setState(InputState.draw);
    linePainter.selectedCorner = grundFlaeche!.walls[5].end;
    await addWall(Linie(angle: 270, length: 0, start: _ausnahmePopup.startingPoint!, end: Punkt.fromPoint(point: Offset.zero)));
    linePainter.selectedCorner = walls.last.end;
    tap(grundFlaeche!.walls.first.start.scaled!);
    linePainter.selectedCorner = walls.last.end;
    tap(grundFlaeche!.walls[6].end.scaled!);
    linePainter.selectedCorner = walls.last.end;
    await addWall(null);

    _drawingAusnahme = false;
    linePainter.isDrawing = false;
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
        case InputState.selectWerkstoff:
          _selectActionPopup.selected = "";
          break;
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
              _selectActionPopup.selected = "";
              Punkt? startPoly = grundFlaeche!.findCornerAtPoint(_werkstoffPopup.startingPoint!.point);
              if (startPoly != null) {
                polyPainter.hiddenCorners.add(startPoly);
              }
              linePainter.isDrawing = true;
              linePainter.selectedCorner = _werkstoffPopup.startingPoint;
            } else {
              finishWerkstoff();
            }
          } else {
            //Fehlercode 2
            AlertInfo().newAlert("Ihre Eingabe waren keine Zahlen! (Code: 2)");
          }

          break;
        default:
          break;
      }
      repaint();
    }
  }

  void handleEinkerbungInput(InputStateEventArgs? args) {
    if (args != null) {
      polyPainter.selectCorner = false;
      polyPainter.selectedCorner = null;
      _drawingAusnahme = false;
      polyPainter.hiddenCorners.clear();
      switch (args.value) {
        case InputState.inputEinkerbung:
          _selectActionPopup.selected = "";
          break;
        case InputState.selectStartingpoint:
          polyPainter.selectCorner = true;
          break;
        case InputState.draw:
          _ausnahmePopup.calcStartingpointWithOffset();
          if (_ausnahmePopup.startingPoint != null) {
            _ausnahmePopup.startingPoint!.initScale(scalingData.scale, scalingData.center);
            _drawingAusnahme = true;
            polyPainter.selectCorner = true;
            _selectActionPopup.selected = "";
            Punkt? startPoly = grundFlaeche!.findCornerAtPoint(_ausnahmePopup.startingPoint!.point);
            if (startPoly != null) {
              polyPainter.hiddenCorners.add(startPoly);
            }
            linePainter.isDrawing = true;
            linePainter.selectedCorner = _ausnahmePopup.startingPoint;
          } else {
            //Fehlercode 3
            AlertInfo().newAlert("Ihre Eingabe waren keine Zahlen! (Code: 3)");
          }
          break;
        default:
          break;
      }
      repaint();
    }
  }

  Future<void> addWall(Linie? wall) async {
    if (wall != null) {
      if (wall.length == 0) {
        if (_drawingAusnahme) {
          Punkt startPoint = _ausnahmePopup.startingPoint!;
          if (walls.isNotEmpty && linePainter.selectedCorner != null) {
            startPoint = linePainter.selectedCorner!;
          }
          double length = await grundFlaeche!.findMaxLength(startPoint, wall.angle, forEinkerbung: true);
          wall = Linie.fromStart(angle: wall.angle, length: length, start: Punkt.fromPoint(point: Offset.zero));
        } else if (_drawingWerkstoff) {
          Punkt startPoint = _werkstoffPopup.startingPoint!;
          if (walls.isNotEmpty && linePainter.selectedCorner != null) {
            startPoint = linePainter.selectedCorner!;
          }
          double length = await grundFlaeche!.findMaxLength(startPoint, wall.angle);
          wall = Linie.fromStart(angle: wall.angle, length: length, start: Punkt.fromPoint(point: Offset.zero));
        }
      }
      if (walls.isEmpty) {
        if (_drawingWerkstoff || _drawingAusnahme) {
          wall = Linie.fromStart(angle: wall.angle, length: wall.length, start: linePainter.selectedCorner!);
          if (!grundFlaeche!.containsFullWall(wall, forEinkerbung: _drawingAusnahme)) {
            polyPainter.hiddenCorners
                .removeWhere((element) => element.point.dx.roundToDouble() == wall!.end.point.dx.roundToDouble() && element.point.dy.roundToDouble() == wall.end.point.dy.roundToDouble());
            AlertInfo().newAlert("Außerhalb des Raums");
            return;
          }
        }
        _wallCount++;
        wall.id = _wallCount;
        walls.add(wall);
        updateDrawingState.broadcast();
      } else {
        if (linePainter.selectedCorner == null) {
          //Fehlercode 1
          AlertInfo().newAlert("Keine Ecke gewählt! (Code: 1)");
          return;
        } else {
          if (linePainter.selectedCorner! == walls.first.start) {
            if (wall.angle <= 180) {
              wall = Linie.fromEnd(angle: wall.angle + 180, length: wall.length, end: walls.first.start);
            } else {
              wall = Linie.fromEnd(angle: wall.angle - 180, length: wall.length, end: walls.first.start);
            }
            if ((_drawingAusnahme || _drawingWerkstoff) && !grundFlaeche!.containsFullWall(wall, forEinkerbung: _drawingAusnahme)) {
              polyPainter.hiddenCorners
                  .removeWhere((element) => element.point.dx.roundToDouble() == wall!.start.point.dx.roundToDouble() && element.point.dy.roundToDouble() == wall.start.point.dy.roundToDouble());
              AlertInfo().newAlert("Außerhalb des Raums");
              return;
            }
            _wallCount++;
            wall.id = _wallCount;
            walls.insert(0, wall);
          } else if (linePainter.selectedCorner! == walls.last.end) {
            wall = Linie.fromStart(angle: wall.angle, length: wall.length, start: walls.last.end);
            if ((_drawingAusnahme || _drawingWerkstoff) && !grundFlaeche!.containsFullWall(wall, forEinkerbung: _drawingAusnahme)) {
              polyPainter.hiddenCorners
                  .removeWhere((element) => element.point.dx.roundToDouble() == wall!.end.point.dx.roundToDouble() && element.point.dy.roundToDouble() == wall.end.point.dy.roundToDouble());
              AlertInfo().newAlert("Außerhalb des Raums");
              return;
            }
            _wallCount++;
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
      } else if (_drawingAusnahme) {
        finishEinkerbung();
      } else {
        finishArea();
      }
    }
    _updateScaleAndCenter();
  }

  void tap(Offset position) {
    if (linePainter.isDrawing) {
      if (polyPainter.selectCorner && _werkstoffPopup.state == InputState.draw || _ausnahmePopup.state == InputState.draw) {
        if (linePainter.selectedCorner == null && walls.isNotEmpty) {
          linePainter.selectedCorner = linePainter.detectClickedCorner(position);
        } else {
          Punkt? wallEnd = grundFlaeche?.detectClickedCorner(position);
          if (wallEnd != null && !polyPainter.hiddenCorners.contains(wallEnd)) {
            Offset diff = wallEnd.point - linePainter.selectedCorner!.point;
            double angle = (diff.direction * (180 / pi)) + 90;
            double length = sqrt(pow(diff.dx, 2) + pow(diff.dy, 2));
            Linie wall = Linie(angle: angle, length: length, start: linePainter.selectedCorner!, end: wallEnd);
            polyPainter.hiddenCorners.add(wallEnd);
            addWall(wall);
          } else if (walls.isNotEmpty) {
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
      } else {
        _werkstoffPopup.startingPoint = null;
      }
    } else if (polyPainter.selectCorner && _ausnahmePopup.state == InputState.selectStartingpoint) {
      polyPainter.selectedCorner = grundFlaeche?.detectClickedCorner(position);
      if (polyPainter.selectedCorner != null) {
        _ausnahmePopup.startingPoint = polyPainter.selectedCorner!;
      } else {
        _ausnahmePopup.startingPoint = null;
      }
    } else {
      if (grundFlaeche != null) {
        for (Einkerbung einkerbung in grundFlaeche!.einkerbungen) {
          for (Overlap overlap in einkerbung.overlaps) {
            if (overlap.editMode) {
              if (overlap.tap(position)) {
                repaint();
                return;
              }
            }
          }
        }
      }
      EventArgs? result = findClickedObject(position);

      if (result != null) {
        //TODO: EDIT
      } else {
        polyPainter.clickedWerkstoff = null;
      }
      clickedEvent.broadcast(result);
    }
    _updateScaleAndCenter();
  }

  EventArgs? findClickedObject(Offset position) {
    EventArgs? result;

    if (grundFlaeche != null) {
      for (DrawedWerkstoff werkstoff in grundFlaeche!.werkstoffe.reversed) {
        if (werkstoff.contains(position)) {
          return werkstoff;
        }
      }
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
      grundFlaeche = Grundflaeche(raumName: _flaechenName, walls: List.from(walls));
      reset();
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
        clickAble = Punkt.fromPoint(point: _werkstoffPopup.startingPoint!.point, hitboxSize: 10);
        clickAble.initScale(scalingData.scale, scalingData.center);
        break;
      default:
        return;
    }
    DrawedWerkstoff drawedWerkstoff = DrawedWerkstoff(clickAble: clickAble, werkstoff: werkstoff, hasBeschriftung: true);

    if (werkstoff.typ == WerkstoffTyp.point && !grundFlaeche!.unscaledPath.contains((drawedWerkstoff.clickAble as Punkt).point)) {
      AlertInfo().newAlert("Außerhalb des Raums");
      reset();
      return;
    }
    grundFlaeche!.werkstoffe.add(drawedWerkstoff);

    grundFlaeche!.werkstoffe.sortBy<num>((element) => element.werkstoff.typ.index);

    for (Einkerbung einkerbung in grundFlaeche!.einkerbungen) {
      einkerbung.findOverlap([drawedWerkstoff]);
    }
    reset();
  }

  void finishEinkerbung() {
    Einkerbung einkerbung = Einkerbung(tiefe: _ausnahmePopup.tiefe, walls: List.from(walls), name: _ausnahmePopup.name);
    einkerbung.initScale(scalingData.scale, scalingData.center);
    einkerbung.findOverlap(grundFlaeche!.werkstoffe);
    grundFlaeche?.addEinkerbung(einkerbung);

    reset();
  }

  void undo() {
    if (_wallCount > 1) {
      walls.removeWhere((wall) {
        if (wall.id == _wallCount) {
          if (wall == walls.first) {
            polyPainter.hiddenCorners
                .removeWhere((element) => element.point.dx.roundToDouble() == wall.start.point.dx.roundToDouble() && element.point.dy.roundToDouble() == wall.start.point.dy.roundToDouble());
          } else {
            polyPainter.hiddenCorners
                .removeWhere((element) => element.point.dx.roundToDouble() == wall.end.point.dx.roundToDouble() && element.point.dy.roundToDouble() == wall.end.point.dy.roundToDouble());
          }
          return true;
        }
        return false;
      });
      _wallCount--;
    } else {
      reset();
    }
    _updateScaleAndCenter();
  }

  void _updateScaleAndCenter() {
    if (scalingData.canvasSize != null) {
      Rect newRect = Rect.zero;
      if (walls.isNotEmpty) {
        newRect = Rect.fromPoints(walls.first.start.point, walls.first.start.point);
      }
      for (Linie wall in walls) {
        newRect = newRect.expandToInclude(Rect.fromPoints(wall.end.point, wall.end.point));
      }
      if (grundFlaeche != null) {
        newRect = newRect.expandToInclude(grundFlaeche!.size);

        //TODO: Maybe not needed
        for (DrawedWerkstoff werkstoff in grundFlaeche!.werkstoffe) {
          newRect = newRect.expandToInclude(werkstoff.clickAble.size);
        }
      }

      double maxScaleX = scalingData.canvasSize!.width / newRect.size.width.abs();
      double maxScaleY = scalingData.canvasSize!.height / newRect.size.height.abs();

      double scale = min(maxScaleX, maxScaleY) * 0.8;

      Offset center = newRect.center;

      center = (center * scale) - scalingData.canvasSize!.center(Offset.zero);

      scalingData = ScalingData(scale: scale, rect: newRect, center: center, canvasSize: scalingData.canvasSize);

      updateScaleRectEvent.broadcast(scalingData);

      _drawWithScale(center);
    } else {
      //Fehlercode 4
      AlertInfo().newAlert("Interner Fehler (Code: 4)");
    }
  }

  void _drawWithScale(Offset center) {
    for (Linie wall in walls) {
      wall.initScale(scalingData.scale, center);
    }
    if (grundFlaeche != null) {
      grundFlaeche!.initScale(scalingData.scale, center);
    }
    if (linePainter.selectedCorner != null) {
      linePainter.selectedCorner!.initScale(scalingData.scale, center);
    }

    linePainter.drawWalls(walls);
    polyPainter.drawGrundflaeche(grundFlaeche);
    repaint();
  }

  void reset() {
    _drawingWerkstoff = false;
    _drawingAusnahme = false;
    _werkstoffPopup.finish();
    _ausnahmePopup.finish();
    polyPainter.selectCorner = false;
    polyPainter.hiddenCorners.clear();
    walls.clear();
    _wallCount = 0;
    linePainter.reset();
    updateDrawingState.broadcast();
  }

  Future<void> displayDialog(BuildContext context) async {
    if (grundFlaeche == null || _drawingWerkstoff || _drawingAusnahme) {
      if (walls.isEmpty) {
        _wallPopup.init(0, true);
        if (_drawingWerkstoff) {
          return _wallPopup.display(context, false);
        } else if (_drawingAusnahme) {
          return _wallPopup.display(context, false);
        }
        return _wallPopup.display(context, true);
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
        if (_drawingWerkstoff) {
          return _wallPopup.display(context, false);
        } else if (_drawingAusnahme) {
          return _wallPopup.display(context, false);
        }
        return _wallPopup.display(context, true);
      } else {
        AlertInfo().newAlert("Kein Punkt gewählt!");
      }
    } else {
      switch (_selectActionPopup.selected) {
        case "":
          _selectActionPopup.display(context);
          break;
        case "Werkstoff":
          _werkstoffPopup.display(context);
          break;
        case "Ausnahme":
          _ausnahmePopup.display(context);
          break;
      }
    }
  }
}
