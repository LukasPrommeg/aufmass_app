import 'dart:math';
import 'package:aufmass_app/PlanPage/Misc/alertinfo.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/clickable.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/einkerbung.dart';
import 'package:aufmass_app/PlanPage/Misc/loadingblur.dart';
import 'package:aufmass_app/PlanPage/Misc/overlap.dart';
import 'package:aufmass_app/PlanPage/PopUP/ausnahmepopup.dart';
import 'package:aufmass_app/PlanPage/PopUP/selectactionpopup.dart';
import 'package:aufmass_app/PlanPage/PopUP/werkstoffinput.dart';
import 'package:aufmass_app/PlanPage/SidemenuInputs/inputhandler.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/flaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/grundflaeche.dart';
import 'package:collection/collection.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitcontroller.dart';
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
  final SelectActionPopup _selectActionPopup = SelectActionPopup();
  final WerkstoffInputPopup _werkstoffPopup = WerkstoffInputPopup();
  final AusnahmePopup _ausnahmePopup = AusnahmePopup();

  //Input
  late InputHandler inputHandler;

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
  final refreshMenuElements = Event();
  final clickedEvent = Event<EventArgs>();
  final clickedGrundEvent = Event<ClickAble>();

  PaintController() {
    inputHandler = InputHandler(
      undoCallback: undo,
      cancelCallback: reset,
      finishCallback: () {
        if (walls.length > 1) {
          addWall(null);
          return true;
        } else {
          AlertInfo().newAlert("Nicht genügend Punkte!");
          return false;
        }
      },
      addLinieCallback: (wall) => addLinieCallback(wall),
      setStartingpointCallback: (punkt) {
        if (grundFlaeche == null) {
          return;
        }
        if (grundFlaeche!.unscaledPath.contains(punkt.getRounded())) {
          punkt.initScale(scalingData.scale, scalingData.center);
          linePainter.selectedCorner = punkt;
          repaint();
        } else {
          linePainter.selectedCorner = null;
        }
      },
      submitStartingpointCallback: (punkt) {
        if (grundFlaeche == null) {
          return false;
        }
        if (grundFlaeche!.unscaledPath.contains(punkt.getRounded())) {
          startDrawing(punkt);
          return true;
        }
        AlertInfo().newAlert("Punkt außerhalb des Raumes");
        linePainter.selectedCorner = null;
        return false;
      },
      presetCallback: (presetName) {
        flaechenName = presetName;
      },
    );

    polyPainter = PolyPainter(repaint: _repaint);
    linePainter = LinePainter(repaint: _repaint);
    _einheitController.updateEinheitEvent.subscribe((args) => repaint());
    _selectActionPopup.selectEvent.subscribe((args) {
      if (args != null) {
        displayDialog(args.context);
      }
    });
    _werkstoffPopup.selectedWerkstoffEvent.subscribe((args) => selectStartingpoint());
    _ausnahmePopup.einkerbungInitEvent.subscribe((args) => selectStartingpoint());
  }

  set flaechenName(String string) {
    _flaechenName = string;
    if (grundFlaeche != null) {
      grundFlaeche!.raumName = string;
    }
    if (string.toLowerCase() == "testwohnzimmer") {
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
/*
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
*/
    reset();
  }

  void repaint() {
    _repaint.value++;
  }

  void selectStartingpoint() {
    polyPainter.selectCorner = true;
    inputHandler.currentlyHandling = CurrentlyHandling.startingPoint;
    refreshMenuElements.broadcast();
    repaint();
  }

  void startDrawing(Punkt punkt) {
    punkt.initScale(scalingData.scale, scalingData.center);
    polyPainter.selectedCorner = null;
    switch (_selectActionPopup.selected) {
      case "Werkstoff":
        _drawingWerkstoff = true;
        if (_werkstoffPopup.selectedWerkstoff!.needsmorePoints(1)) {
          Punkt? startPoly = grundFlaeche!.findCornerAtPoint(punkt.point);
          if (startPoly != null) {
            polyPainter.hiddenCorners.add(startPoly);
          }
          linePainter.isDrawing = true;
          linePainter.selectedCorner = punkt;

          inputHandler.currentlyHandling = CurrentlyHandling.lines;
          refreshMenuElements.broadcast();
        } else {
          finishWerkstoff();
        }
        break;
      case "Ausnahme":
        _drawingAusnahme = true;
        Punkt? startPoly = grundFlaeche!.findCornerAtPoint(punkt.point);
        if (startPoly != null) {
          polyPainter.hiddenCorners.add(startPoly);
        }
        linePainter.isDrawing = true;
        linePainter.selectedCorner = punkt;

        inputHandler.currentlyHandling = CurrentlyHandling.lines;
        refreshMenuElements.broadcast();

        break;
      default:
        AlertInfo().newAlert("WTF GEHT HIAZ");
        break;
    }
  }

  void addLinieCallback(Linie wall) async {
    LoadingBlur().enableBlur();
    addWall(wall).then((value) {
      Linie? added = walls.singleWhereOrNull((element) => _wallCount == element.id);
      if (added == null) {
        //TODO: Keine ahnung wos donn passieren suit mann
        AlertInfo().newAlert("Letzte Wand nicht gefunden!");
      } else if (added == walls.first && _wallCount != 1) {
        linePainter.selectedCorner = walls.first.start;
      } else {
        linePainter.selectedCorner = walls.last.end;
      }

      updateInputHandler();

      LoadingBlur().disableBlur();
    });
  }

  Future<void> addWall(Linie? wall) async {
    if (wall != null) {
      if (wall.length == 0 && inputHandler.currentlyHandling == CurrentlyHandling.lines) {
        try {
          Punkt startPoint = linePainter.selectedCorner!;
          double length = await grundFlaeche!.findMaxLength(startPoint, wall.angle);
          if (length > 0) {
            wall = Linie.fromStart(angle: wall.angle, length: length, start: Punkt.fromPoint(point: Offset.zero));
          } else {
            AlertInfo().newAlert("Fehler bei der Ermittlung der maximalen Länge");
          }
        } catch (ex) {
          AlertInfo().newAlert("Fehler beim Startpunkt!");
        }
      }
      if (walls.isEmpty) {
        if (_drawingWerkstoff || _drawingAusnahme) {
          wall = Linie.fromStart(angle: wall!.angle, length: wall.length, start: linePainter.selectedCorner!);
          if (!grundFlaeche!.containsFullWall(wall, forEinkerbung: _drawingAusnahme)) {
            polyPainter.hiddenCorners.removeWhere((element) => element.equals(wall!.end));
            AlertInfo().newAlert("Außerhalb des Raums");
            return;
          }
        }
        _wallCount++;
        wall!.id = _wallCount;
        walls.add(wall);
        refreshMenuElements.broadcast();
      } else {
        if (linePainter.selectedCorner == null) {
          //Fehlercode 1
          AlertInfo().newAlert("Keine Ecke gewählt! (Code: 1)");
          return;
        } else {
          if (linePainter.selectedCorner! == walls.first.start) {
            if (wall!.angle <= 180) {
              wall = Linie.fromEnd(angle: wall.angle + 180, length: wall.length, end: walls.first.start);
            } else {
              wall = Linie.fromEnd(angle: wall.angle - 180, length: wall.length, end: walls.first.start);
            }
            if ((_drawingAusnahme || _drawingWerkstoff) && !grundFlaeche!.containsFullWall(wall, forEinkerbung: _drawingAusnahme)) {
              polyPainter.hiddenCorners.removeWhere((element) => element.equals(wall!.start));
              AlertInfo().newAlert("Außerhalb des Raums");
              return;
            }
            _wallCount++;
            wall.id = _wallCount;
            walls.insert(0, wall);
          } else if (linePainter.selectedCorner! == walls.last.end) {
            wall = Linie.fromStart(angle: wall!.angle, length: wall.length, start: walls.last.end);
            if ((_drawingAusnahme || _drawingWerkstoff) && !grundFlaeche!.containsFullWall(wall, forEinkerbung: _drawingAusnahme)) {
              polyPainter.hiddenCorners.removeWhere((element) => element.equals(wall!.end));
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
        if (!_werkstoffPopup.selectedWerkstoff!.needsmorePoints(walls.length + 1)) {
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
      if (polyPainter.selectCorner && _drawingAusnahme || _drawingWerkstoff) {
        if (linePainter.selectedCorner == null && walls.isNotEmpty) {
          linePainter.selectedCorner = linePainter.detectClickedCorner(position);
          updateInputHandler();
        } else {
          Punkt? wallEnd = grundFlaeche?.detectClickedCorner(position);
          if (wallEnd != null && !polyPainter.hiddenCorners.contains(wallEnd)) {
            Offset diff = wallEnd.point - linePainter.selectedCorner!.point;
            double angle = (diff.direction * (180 / pi)) + 90;
            double length = sqrt(pow(diff.dx, 2) + pow(diff.dy, 2));
            Linie wall = Linie(angle: angle, length: length, start: linePainter.selectedCorner!, end: wallEnd);
            polyPainter.hiddenCorners.add(wallEnd);
            addLinieCallback(wall);
          } else if (walls.isNotEmpty) {
            linePainter.selectedCorner = linePainter.detectClickedCorner(position);
            updateInputHandler();
          }
        }
      } else {
        linePainter.selectedCorner = linePainter.detectClickedCorner(position);
        updateInputHandler();
      }
    } else if (polyPainter.selectCorner && inputHandler.currentlyHandling == CurrentlyHandling.startingPoint) {
      polyPainter.selectedCorner = grundFlaeche?.detectClickedCorner(position);
      if (polyPainter.selectedCorner != null) {
        inputHandler.updateStartingpointInput(selectedPunkt: polyPainter.selectedCorner!);
        refreshMenuElements.broadcast();
        linePainter.selectedCorner = null;
      } else {
        inputHandler.updateStartingpointInput();
        linePainter.selectedCorner = null;
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

  void updateInputHandler() {
    bool drawingGrundflache = false;
    if (grundFlaeche == null) {
      drawingGrundflache = true;
    }

    if (walls.isEmpty) {
      inputHandler.updateLinienInput(
        drawingGrundflache: drawingGrundflache,
        isFirstWall: true,
      );
    } else if (linePainter.selectedCorner != null) {
      if (linePainter.selectedCorner! == walls.first.start) {
        if (walls.first.angle <= 180) {
          inputHandler.updateLinienInput(
            drawingGrundflache: drawingGrundflache,
            lastWallAngle: walls.first.angle + 180,
          );
        } else {
          inputHandler.updateLinienInput(
            drawingGrundflache: drawingGrundflache,
            lastWallAngle: walls.first.angle - 180,
          );
        }
      } else if (linePainter.selectedCorner! == walls.last.end) {
        inputHandler.updateLinienInput(
          drawingGrundflache: drawingGrundflache,
          lastWallAngle: walls.last.angle,
        );
      }
    }
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
    grundFlaeche = Grundflaeche(raumName: _flaechenName, walls: List.from(walls));
    reset();
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
        clickAble = Punkt.fromPoint(point: inputHandler.startingPoint!.point, hitboxSize: 10);
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
            polyPainter.hiddenCorners.removeWhere((element) => element.equals(wall.start));
          } else {
            polyPainter.hiddenCorners.removeWhere((element) => element.equals(wall.end));
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
    _selectActionPopup.selected = "";
    polyPainter.selectCorner = false;
    polyPainter.selectedCorner = null;
    polyPainter.hiddenCorners.clear();
    walls.clear();
    _wallCount = 0;
    linePainter.reset();
    updateInputHandler();
    inputHandler.updateStartingpointInput();
    inputHandler.currentlyHandling = CurrentlyHandling.nothing;
    refreshMenuElements.broadcast();
  }

  Future<void> displayDialog(BuildContext context) async {
    if (grundFlaeche != null) {
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
