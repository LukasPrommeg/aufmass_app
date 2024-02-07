import 'package:aufmass_app/2D_Objects/clickable.dart';
import 'package:aufmass_app/2D_Objects/corner.dart';
import 'package:aufmass_app/2D_Objects/einkerbung.dart';
import 'package:aufmass_app/2D_Objects/flaeche.dart';
import 'package:aufmass_app/2D_Objects/wall.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class Overlap {
  final Einkerbung einkerbung;
  final DrawedWerkstoff werkstoff;
  final List<Corner> laibungIntersects = [];
  final List<Wall> laibungOverlaps = [];
  Flaeche? flaeche;

  bool editMode = false;
  bool _isOverlapping = false;

  bool get isOverlapping {
    return _isOverlapping;
  }

  Overlap({required this.einkerbung, required this.werkstoff}) {
    print(werkstoff.amount);

    List<Wall> lines = [];

    switch (werkstoff.werkstoff.typ) {
      case WerkstoffTyp.flaeche:
        lines = List<Wall>.from((werkstoff.clickAble as Flaeche).walls);
        lines.add((werkstoff.clickAble as Flaeche).lastWall);
        break;
      case WerkstoffTyp.linie:
        lines = [(werkstoff.clickAble as Wall)];
        break;
      default:
        return;
    }
    List<Wall> laibungen = calcLaibungIntersects(lines);
    laibungOverlaps.addAll(laibungen);
    List<Wall> werkstoffLines = calcWerkstofflinesInsideEinkerbung(lines);

    if (werkstoff.werkstoff.typ == WerkstoffTyp.flaeche) {
      laibungOverlaps.addAll(calcBorderInsideWerkstoffarea());

      List<Wall> walls = List.from(laibungOverlaps);
      walls.addAll(werkstoffLines);

      walls = sortWallsAndRemoveDuplicates(walls);

      walls.removeLast();
      flaeche = Flaeche(walls: walls);
      flaeche!.selected = true;
      laibungIntersects.clear();
    } else if (werkstoff.werkstoff.typ == WerkstoffTyp.linie) {
      laibungOverlaps.addAll(werkstoffLines);
    }

    List<Wall> temp = List.from(laibungOverlaps);
    laibungOverlaps.clear();
    laibungOverlaps.addAll(removeDuplicateWalls(temp));

    if (werkstoff.werkstoff.typ == WerkstoffTyp.linie) {
      if (einkerbung.tiefe.isFinite) {
        for (Corner corner in laibungIntersects) {
          if (corner.selected) {
            werkstoff.amount += einkerbung.tiefe;
            print("+" + einkerbung.tiefe.toStringAsFixed(2));
          } else {
            werkstoff.amount -= einkerbung.tiefe;
            print("-" + einkerbung.tiefe.toStringAsFixed(2));
          }
        }
      }
    } else if (werkstoff.werkstoff.typ == WerkstoffTyp.flaeche) {
      if (einkerbung.tiefe.isFinite) {
        for (Wall wall in laibungOverlaps) {
          if (wall.selected) {
            werkstoff.amount += wall.length * einkerbung.tiefe;
            print("+" + (wall.length * einkerbung.tiefe).toStringAsFixed(2));
          } else {
            werkstoff.amount -= wall.length * einkerbung.tiefe;
            print("-" + (wall.length * einkerbung.tiefe).toStringAsFixed(2));
          }
        }
      }
    }

    if (laibungIntersects.isNotEmpty || laibungOverlaps.isNotEmpty || flaeche != null) {
      _isOverlapping = true;
    }
  }

  List<Wall> removeDuplicateWalls(List<Wall> walls) {
    List<Wall> avaivable = List.from(walls);
    for (int i = 0; i < avaivable.length; i++) {
      List<Wall> matches = avaivable.where((element) => wallsAreEqual(avaivable[i], element)).toList();
      matches.removeLast();
      for (Wall match in matches) {
        avaivable.remove(match);
      }
    }
    return avaivable;
  }

  List<Wall> sortWallsAndRemoveDuplicates(List<Wall> walls) {
    List<Wall> avaivable = removeDuplicateWalls(walls);

    List<Wall> out = [avaivable.first];
    avaivable.removeAt(0);

    for (int i = 1; i < walls.length; i++) {
      Wall? matchEndStart = avaivable.firstWhereOrNull((element) => doEndsMatch(out.last.end, element.start));
      Wall? matchEndEnd = avaivable.firstWhereOrNull((element) => doEndsMatch(out.last.end, element.end));
      if (matchEndEnd != null) {
        avaivable.remove(matchEndEnd);
        matchEndEnd = Wall.fromPoints(start: matchEndEnd.end, end: matchEndEnd.start);
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

  bool wallsAreEqual(Wall wall1, Wall wall2) {
    if (wall1.start.point.dx.roundToDouble() == wall2.start.point.dx.roundToDouble() &&
        wall1.start.point.dy.roundToDouble() == wall2.start.point.dy.roundToDouble() &&
        wall1.end.point.dx.roundToDouble() == wall2.end.point.dx.roundToDouble() &&
        wall1.end.point.dy.roundToDouble() == wall2.end.point.dy.roundToDouble()) {
      return true;
    } else if (wall2.start.point.dx.roundToDouble() == wall1.start.point.dx.roundToDouble() &&
        wall2.start.point.dy.roundToDouble() == wall1.start.point.dy.roundToDouble() &&
        wall2.end.point.dx.roundToDouble() == wall1.end.point.dx.roundToDouble() &&
        wall2.end.point.dy.roundToDouble() == wall1.end.point.dy.roundToDouble()) {
      return true;
    }
    return false;
  }

  List<Wall> calcLaibungIntersects(List<Wall> lines) {
    List<Wall> result = [];
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
            Wall laibungOverlap = calcLengthOfOverlap(Wall.clone(borderSide));
            laibungOverlap.selected = true;
            result.add(laibungOverlap);
          }
        }
      }
    }
    einkerbung.walls.removeLast();
    return result;
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
      Path overlap = Path.combine(PathOperation.intersect, borderSide.unscaledPath, werkstoff.clickAble.unscaledPath);
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
      if (einkerbung.unscaledPath.contains(input.start.point) && werkstoff.clickAble.unscaledPath.contains(input.start.point)) {
        limits.add(Corner.clone(input.start));
      } else if (einkerbung.unscaledPath.contains(input.end.point) && werkstoff.clickAble.unscaledPath.contains(input.end.point)) {
        limits.add(Corner.clone(input.end));
      }
    }
    if (limits.length == 2) {
      return Wall.fromPoints(start: Corner.clone(limits.first), end: Corner.clone(limits.last));
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
      if (clicked is Corner) {
        werkstoff.amount += einkerbung.tiefe * modification;
      } else if (clicked is Wall) {
        werkstoff.amount += clicked.length * modification;
      }
    } else if (werkstoff.werkstoff.typ == WerkstoffTyp.flaeche) {
      if (clicked is Wall) {
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
      for (Wall wall in laibungOverlaps) {
        if (debug) {
          wall.paint(canvas, Colors.yellow, 5);
        }
        wall.paintHB(canvas);
      }
      for (Corner corner in laibungIntersects) {
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
        modifyAmountOfWerkstoff(corner);
        return true;
      }
    }
    for (Wall wall in laibungOverlaps) {
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
