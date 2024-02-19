import 'package:aufmass_app/PlanPage/2D_Objects/clickable.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/einkerbung.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/flaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/linie.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class Overlap {
  final Einkerbung einkerbung;
  final DrawedWerkstoff werkstoff;
  final List<Punkt> laibungIntersects = [];
  final List<Linie> laibungOverlaps = [];
  Flaeche? flaeche;

  bool editMode = false;
  bool _isOverlapping = false;

  bool get isOverlapping {
    return _isOverlapping;
  }

  Overlap({required this.einkerbung, required this.werkstoff}) {
    List<Linie> lines = [];

    switch (werkstoff.werkstoff.typ) {
      case WerkstoffTyp.flaeche:
        lines = List<Linie>.from((werkstoff.clickAble as Flaeche).walls);
        lines.add((werkstoff.clickAble as Flaeche).lastWall);
        break;
      case WerkstoffTyp.linie:
        lines = [(werkstoff.clickAble as Linie)];
        break;
      default:
        return;
    }
    List<Linie> laibungen = calcLaibungIntersects(lines);
    laibungOverlaps.addAll(laibungen);
    List<Linie> werkstoffLines = calcWerkstofflinesInsideEinkerbung(lines);

    List<Linie> walls = List.from(laibungOverlaps);
    walls.addAll(werkstoffLines);

    if (werkstoff.werkstoff.typ == WerkstoffTyp.flaeche && walls.isNotEmpty) {
      laibungOverlaps.addAll(calcBorderInsideWerkstoffarea());

      walls.addAll(laibungOverlaps);

      walls = sortWallsAndRemoveDuplicates(walls);

      walls.removeLast();

      flaeche = Flaeche(walls: walls);
      flaeche!.selected = true;
      laibungIntersects.clear();
    } else if (werkstoff.werkstoff.typ == WerkstoffTyp.linie) {
      laibungOverlaps.addAll(werkstoffLines);
    }

    List<Linie> temp = List.from(laibungOverlaps);
    laibungOverlaps.clear();
    laibungOverlaps.addAll(removeDuplicateWalls(temp));

    if (werkstoff.werkstoff.typ == WerkstoffTyp.linie) {
      if (einkerbung.tiefe.isFinite) {
        for (Punkt corner in laibungIntersects) {
          if (corner.selected) {
            werkstoff.amount += einkerbung.tiefe;
          } else {
            werkstoff.amount -= einkerbung.tiefe;
          }
        }
      }
    } else if (werkstoff.werkstoff.typ == WerkstoffTyp.flaeche) {
      if (einkerbung.tiefe.isFinite) {
        for (Linie wall in laibungOverlaps) {
          if (wall.selected) {
            werkstoff.amount += wall.length * einkerbung.tiefe;
          } else {
            werkstoff.amount -= wall.length * einkerbung.tiefe;
          }
        }
      }
    }

    if (laibungIntersects.isNotEmpty || laibungOverlaps.isNotEmpty || flaeche != null) {
      _isOverlapping = true;
    }
  }

  List<Linie> removeDuplicateWalls(List<Linie> walls) {
    List<Linie> avaivable = List.from(walls);
    int nmatches = 0;
    for (int i = 0; i < avaivable.length; i++) {
      List<Linie> matches = avaivable.where((element) => wallsAreEqual(avaivable[i], element)).toList();
      matches.removeLast();
      for (Linie match in matches) {
        avaivable.remove(match);
      }
      nmatches += matches.length;
    }
    print("REMOVED ${nmatches} MATCHES OF ${walls.length} ENTRIES");

    return avaivable;
  }

  List<Linie> sortWallsAndRemoveDuplicates(List<Linie> walls) {
    if (walls.isEmpty) {
      return [];
    }

    List<Linie> avaivable = removeDuplicateWalls(walls);
    //TODO: Sometime removeDuplicateWalls doesnt work on 1 Wall
    //avaivable = removeDuplicateWalls(avaivable);

    List<Linie> out = [avaivable.first];
    avaivable.removeAt(0);

    for (int i = 1; i < walls.length; i++) {
      Linie? matchEndStart = avaivable.firstWhereOrNull((element) => doEndsMatch(out.last.end, element.start));
      Linie? matchEndEnd = avaivable.firstWhereOrNull((element) => doEndsMatch(out.last.end, element.end));
      if (matchEndEnd != null) {
        avaivable.remove(matchEndEnd);
        matchEndEnd = Linie.fromPoints(start: matchEndEnd.end, end: matchEndEnd.start);
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

  bool doEndsMatch(Punkt end1, Punkt end2) {
    if (end1.point.dx.roundToDouble() == end2.point.dx.roundToDouble() && end1.point.dy.roundToDouble() == end2.point.dy.roundToDouble()) {
      return true;
    }
    return false;
  }

  bool wallsAreEqual(Linie wall1, Linie wall2) {
    if (wall1.start.point.dx.roundToDouble() == wall2.start.point.dx.roundToDouble() &&
        wall1.start.point.dy.roundToDouble() == wall2.start.point.dy.roundToDouble() &&
        wall1.end.point.dx.roundToDouble() == wall2.end.point.dx.roundToDouble() &&
        wall1.end.point.dy.roundToDouble() == wall2.end.point.dy.roundToDouble()) {
      return true;
    } else if (wall1.start.point.dx.roundToDouble() == wall2.end.point.dx.roundToDouble() &&
        wall1.start.point.dy.roundToDouble() == wall2.end.point.dy.roundToDouble() &&
        wall1.end.point.dx.roundToDouble() == wall2.start.point.dx.roundToDouble() &&
        wall1.end.point.dy.roundToDouble() == wall2.start.point.dy.roundToDouble()) {
      return true;
    }
    return false;
  }

  List<Linie> calcLaibungIntersects(List<Linie> lines) {
    List<Linie> result = [];
    einkerbung.walls.add(einkerbung.lastWall);
    for (Linie borderSide in einkerbung.walls) {
      for (Linie line in lines) {
        Path lineIntersect = Path.combine(PathOperation.intersect, line.unscaledPath, borderSide.unscaledPath);
        if (!lineIntersect.getBounds().isEmpty) {
          Offset diff = lineIntersect.getBounds().topLeft - lineIntersect.getBounds().bottomRight;
          if (diff.distance.abs() <= 0.1) {
            Offset point = lineIntersect.getBounds().center;
            if (laibungIntersects.where((element) => element.point.dx.roundToDouble() == point.dx.roundToDouble() && element.point.dy.roundToDouble() == point.dy.roundToDouble()).isEmpty) {
              Punkt laibungIntersect = Punkt.fromPoint(point: lineIntersect.getBounds().center);
              laibungIntersect.selected = true;
              laibungIntersects.add(laibungIntersect);
            }
          } else {
            Linie laibungOverlap = calcLengthOfOverlap(Linie.clone(borderSide));
            if (laibungOverlap.length > 0) {
              laibungOverlap.selected = true;
              result.add(laibungOverlap);
            }
          }
        }
      }
    }
    einkerbung.walls.removeLast();
    return result;
  }

  List<Linie> calcWerkstofflinesInsideEinkerbung(List<Linie> lines) {
    List<Linie> result = [];
    for (Linie line in lines) {
      Path overlap = Path.combine(PathOperation.intersect, line.unscaledPath, einkerbung.unscaledPath);
      if (!overlap.getBounds().isEmpty) {
        if (overlap.getBounds().size.longestSide >= 0.1) {
          Linie laibungOverlap = calcLengthOfOverlap(Linie.clone(line));
          laibungOverlap.selected = true;
          result.add(laibungOverlap);
        }
      }
    }
    return result;
  }

  List<Linie> calcBorderInsideWerkstoffarea() {
    List<Linie> result = [];
    einkerbung.walls.add(einkerbung.lastWall);
    for (Linie borderSide in einkerbung.walls) {
      Path overlap = Path.combine(PathOperation.intersect, borderSide.unscaledPath, werkstoff.clickAble.unscaledPath);
      if (!overlap.getBounds().isEmpty) {
        if (overlap.getBounds().size.longestSide >= 0.1) {
          Linie laibungOverlap = calcLengthOfOverlap(Linie.clone(borderSide));
          laibungOverlap.selected = true;
          result.add(laibungOverlap);
        }
      }
    }
    einkerbung.walls.removeLast();
    return result;
  }

  Linie calcLengthOfOverlap(Linie input) {
    List<Punkt> limits = [];

    for (Punkt end in laibungIntersects) {
      if (input.unscaledPath.contains(end.point)) {
        limits.add(end);
      }
    }
    if (limits.length == 1) {
      if (einkerbung.unscaledPath.contains(input.start.point) && werkstoff.clickAble.unscaledPath.contains(input.start.point)) {
        limits.add(Punkt.clone(input.start));
      } else if (einkerbung.unscaledPath.contains(input.end.point) && werkstoff.clickAble.unscaledPath.contains(input.end.point)) {
        limits.add(Punkt.clone(input.end));
      }
    }
    if (limits.length == 2) {
      return Linie.fromPoints(start: Punkt.clone(limits.first), end: Punkt.clone(limits.last));
    } else if (limits.isEmpty) {
      return input;
    } else {
      //TODO: FEHLERCODE
      //AlertInfo().newAlert("ZU KOMPLIZIERT FÜR OVERLAPS");
      return input;
    }
  }

  void modifyAmountOfWerkstoff(ClickAble clicked) {
    int modification = 1;

    if (!clicked.selected) {
      modification = -1;
    }

    if (werkstoff.werkstoff.typ == WerkstoffTyp.linie) {
      if (clicked is Punkt) {
        werkstoff.amount += einkerbung.tiefe * modification;
      } else if (clicked is Linie) {
        werkstoff.amount += clicked.length * modification;
      }
    } else if (werkstoff.werkstoff.typ == WerkstoffTyp.flaeche) {
      if (clicked is Linie) {
        werkstoff.amount += clicked.length * einkerbung.tiefe * modification;
      } else if (clicked is Flaeche) {
        werkstoff.amount += clicked.area * modification;
      }
    }

    werkstoff.amount = werkstoff.amount.roundToDouble();
  }

  void paint(Canvas canvas, {bool debug = false}) {
    if (editMode) {
      if (flaeche != null) {
        if (debug) {
          flaeche!.paint(canvas, Colors.red, 2.5);
        }
        flaeche!.paintHB(canvas);
      }
      for (Linie wall in laibungOverlaps) {
        if (debug) {
          wall.paint(canvas, Colors.yellow, 5);
        }
        wall.paintHB(canvas);
      }
      for (Punkt corner in laibungIntersects) {
        if (debug) {
          corner.paint(canvas, Colors.green, 10);
        }
        corner.paintHB(canvas);
      }
    }
  }

  void initScale(double scale, Offset center) {
    if (flaeche != null) {
      flaeche!.initScale(scale, center);
    }
    for (Punkt corner in laibungIntersects) {
      corner.initScale(scale, center);
    }
    for (Linie wall in laibungOverlaps) {
      wall.initScale(scale, center);
    }
  }

  bool tap(Offset position) {
    for (Punkt corner in laibungIntersects) {
      if (corner.contains(position)) {
        corner.selected = !corner.selected;
        modifyAmountOfWerkstoff(corner);
        return true;
      }
    }
    for (Linie wall in laibungOverlaps) {
      if (wall.contains(position)) {
        wall.selected = !wall.selected;
        modifyAmountOfWerkstoff(wall);
        return true;
      }
    }
    if (flaeche != null && flaeche!.contains(position)) {
      flaeche!.selected = !flaeche!.selected;
      modifyAmountOfWerkstoff(flaeche!);
      return true;
    }
    return false;
  }
}
