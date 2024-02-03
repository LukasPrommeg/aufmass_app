import 'package:aufmass_app/2D_Objects/clickable.dart';
import 'package:aufmass_app/2D_Objects/corner.dart';
import 'package:aufmass_app/2D_Objects/einkerbung.dart';
import 'package:aufmass_app/2D_Objects/flaeche.dart';
import 'package:aufmass_app/2D_Objects/wall.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class Overlap {
  final Einkerbung einkerbung;
  final ClickAble overlapObj;
  final Werkstoff werkstoff;
  final List<Corner> laibungIntersects = [];
  final List<Wall> laibungOverlaps = []; //TODO: Duplikate!!
  Flaeche? flaeche;

  bool editMode = false;
  bool _isOverlapping = false;

  bool get isOverlapping {
    return _isOverlapping;
  }

  Overlap({required this.einkerbung, required this.overlapObj, required this.werkstoff}) {
    List<Wall> lines = [];

    switch (werkstoff.typ) {
      case WerkstoffTyp.flaeche:
        lines = List<Wall>.from((overlapObj as Flaeche).walls);
        lines.add((overlapObj as Flaeche).lastWall);
        break;
      case WerkstoffTyp.linie:
        lines = [(overlapObj as Wall)];
        break;
      default:
        return;
    }
    calcLaibungIntersects(lines);
    List<Wall> werkstoffLines = calcWerkstofflinesInsideEinkerbung(lines);

    if (werkstoff.typ == WerkstoffTyp.flaeche) {
      laibungOverlaps.addAll(calcBorderInsideWerkstoffarea());

      List<Wall> walls = List.from(laibungOverlaps);
      walls.addAll(werkstoffLines);
      walls = sortWalls(walls);

      walls.removeLast();
      flaeche = Flaeche(walls: walls);
      flaeche!.selected = true;
      laibungIntersects.clear();
    } else if (werkstoff.typ == WerkstoffTyp.linie) {
      laibungOverlaps.addAll(werkstoffLines);
    }
    if (laibungIntersects.isNotEmpty || laibungOverlaps.isNotEmpty || flaeche != null) {
      _isOverlapping = true;
    }
  }

  List<Wall> sortWalls(List<Wall> walls) {
    List<Wall> avaivable = List.from(walls);
    List<Wall> out = [avaivable.first];
    avaivable.removeAt(0);

    for (int i = 1; i < walls.length; i++) {
      Wall? matchEndStart = avaivable.singleWhereOrNull((element) => doEndsMatch(out.last.end, element.start));
      Wall? matchEndEnd = avaivable.singleWhereOrNull((element) => doEndsMatch(out.last.end, element.end));
      if (matchEndEnd != null) {
        avaivable.remove(matchEndEnd);
        matchEndEnd = Wall(angle: matchEndEnd.angle, length: matchEndEnd.length, start: matchEndEnd.end, end: matchEndEnd.start);
        out.add(matchEndEnd);
      } else if (matchEndStart != null) {
        out.add(matchEndStart);
        avaivable.remove(matchEndStart);
      }
    }
/*    try {
      out.add(avaivable.single);
    } catch (e) {
      //TODO: ERROR beim Sortieren
      print("ERROR beim Sortieren");
    }*/
    return out;
  }

  bool doEndsMatch(Corner end1, Corner end2) {
    if (end1.point.dx.roundToDouble() == end2.point.dx.roundToDouble() && end1.point.dy.roundToDouble() == end2.point.dy.roundToDouble()) {
      return true;
    }
    return false;
  }

  void calcLaibungIntersects(List<Wall> lines) {
    einkerbung.walls.add(einkerbung.lastWall);
    for (Wall borderSide in einkerbung.walls) {
      for (Wall line in lines) {
        Path lineIntersect = Path.combine(PathOperation.intersect, line.unscaledPath, borderSide.unscaledPath);
        if (!lineIntersect.getBounds().isEmpty) {
          Offset diff = lineIntersect.getBounds().topLeft - lineIntersect.getBounds().bottomRight;
          if (diff.distance.abs() <= 0.1) {
            Offset point = lineIntersect.getBounds().center;
            if (laibungIntersects.where((element) => element.point.dx.roundToDouble() == point.dx.roundToDouble() && element.point.dy.roundToDouble() == point.dy.roundToDouble()).isEmpty) {
              Corner laibungIntersect = Corner.fromPoint(point: lineIntersect.getBounds().center);
              laibungIntersect.selected = true;
              laibungIntersects.add(laibungIntersect);
            }
          } else {
            Wall laibungOverlap = Wall.clone(borderSide);
            laibungOverlap.selected = true;
            laibungOverlaps.add(laibungOverlap);
          }
        }
      }
    }
    einkerbung.walls.removeLast();
  }

  List<Wall> calcWerkstofflinesInsideEinkerbung(List<Wall> lines) {
    List<Wall> result = [];
    for (Wall line in lines) {
      Path overlap = Path.combine(PathOperation.intersect, line.unscaledPath, einkerbung.unscaledPath);
      if (!overlap.getBounds().isEmpty) {
        if (overlap.getBounds().size.longestSide >= 0.1) {
          Wall laibungOverlap = calcLengthOfOverlap(Wall.clone(line));
          laibungOverlap.selected = true;
          result.add(laibungOverlap);
        }
      }
    }
    return result;
  }

  List<Wall> calcBorderInsideWerkstoffarea() {
    List<Wall> result = [];
    einkerbung.walls.add(einkerbung.lastWall);
    for (Wall borderSide in einkerbung.walls) {
      Path overlap = Path.combine(PathOperation.intersect, borderSide.unscaledPath, overlapObj.unscaledPath);
      if (!overlap.getBounds().isEmpty) {
        if (overlap.getBounds().size.longestSide >= 0.1) {
          Wall laibungOverlap = calcLengthOfOverlap(Wall.clone(borderSide));
          laibungOverlap.selected = true;
          result.add(laibungOverlap);
        }
      }
    }
    einkerbung.walls.removeLast();
    return result;
  }

  Wall calcLengthOfOverlap(Wall input) {
    List<Corner> limits = [];

    for (Corner end in laibungIntersects) {
      if (input.unscaledPath.contains(end.point)) {
        limits.add(end);
      }
    }
    if (limits.length == 1) {
      if (einkerbung.unscaledPath.contains(input.start.point) && overlapObj.unscaledPath.contains(input.start.point)) {
        limits.add(Corner.clone(input.start));
      } else if (einkerbung.unscaledPath.contains(input.end.point) && overlapObj.unscaledPath.contains(input.end.point)) {
        limits.add(Corner.clone(input.end));
      }
    }
    if (limits.length == 2) {
      return Wall(angle: 0, length: 0, start: Corner.clone(limits.first), end: Corner.clone(limits.last));
    } else if (limits.isEmpty) {
      return input;
    } else {
      //TODO: FEHLERCODE
      //AlertInfo().newAlert("ZU KOMPLIZIERT FÜR OVERLAPS");
      return input;
    }
  }

  void paint(Canvas canvas, {bool debug = false}) {
    if (editMode) {
      for (Corner corner in laibungIntersects) {
        if (debug) {
          corner.paint(canvas, Colors.green, 10);
        }
        corner.paintHB(canvas);
      }
      for (Wall wall in laibungOverlaps) {
        if (debug) {
          wall.paint(canvas, Colors.yellow, 5);
        }
        wall.paintHB(canvas);
      }
      if (flaeche != null) {
        if (debug) {
          flaeche!.paint(canvas, Colors.red, 2.5);
        }
        flaeche!.paintHB(canvas);
      }
    }
  }

  void initScale(double scale, Offset center) {
    if (flaeche != null) {
      flaeche!.initScale(scale, center);
    }
    for (Corner corner in laibungIntersects) {
      corner.initScale(scale, center);
    }
    for (Wall wall in laibungOverlaps) {
      wall.initScale(scale, center);
    }
  }

  bool tap(Offset position) {
    for (Corner corner in laibungIntersects) {
      if (corner.contains(position)) {
        corner.selected = !corner.selected;
        return true;
      }
    }
    for (Wall wall in laibungOverlaps) {
      if (wall.contains(position)) {
        wall.selected = !wall.selected;
        return true;
      }
    }
    if (flaeche != null && flaeche!.contains(position)) {
      flaeche!.selected = !flaeche!.selected;
      return true;
    }
    return false;
  }
}
