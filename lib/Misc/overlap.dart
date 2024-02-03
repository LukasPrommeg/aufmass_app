import 'dart:ui';

import 'package:aufmass_app/2D_Objects/clickable.dart';
import 'package:aufmass_app/2D_Objects/corner.dart';
import 'package:aufmass_app/2D_Objects/einkerbung.dart';
import 'package:aufmass_app/2D_Objects/flaeche.dart';
import 'package:aufmass_app/2D_Objects/wall.dart';
import 'package:aufmass_app/Misc/alertinfo.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:flutter/material.dart';

class Overlap {
  final Einkerbung einkerbung;
  final ClickAble overlapObj;
  final Werkstoff werkstoff;
  final List<Corner> laibungIntersects = [];
  final List<Wall> laibungOverlaps = [];
  //final Map<Corner, bool> laibungOverlaps = <Corner, bool>{};
  //final Map<String, List<Werkstoff>> laibungOverlaps = <String, List<Werkstoff>>{};
  Flaeche? flaeche;

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
    calcWerkstofflinesInsideEinkerbung(lines);

    if (werkstoff.typ == WerkstoffTyp.flaeche) {
      calcBorderInsideWerkstoffarea();
      List<Wall> walls = List.from(laibungOverlaps);
      walls.removeLast();
      flaeche = Flaeche(walls: walls);
    }
    //calcEinkerbungBorderOverlaps(lines);
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
              laibungIntersects.add(Corner.fromPoint(point: lineIntersect.getBounds().center));
            }
          } else {
            laibungOverlaps.add(Wall.clone(borderSide));
          }
        }
      }
    }
    einkerbung.walls.removeLast();
    print("FOUND " + laibungIntersects.length.toString() + " INTERSECTS");
    print("FOUND " + laibungOverlaps.length.toString() + " OVERLAPS");
  }

/*
  void calcEinkerbungBorderOverlaps(List<Wall> lines) {
    einkerbung.walls.add(einkerbung.lastWall);
    for (Wall borderSide in einkerbung.walls) {
      Path areaLineIntersect = Path.combine(PathOperation.intersect, borderSide.unscaledPath, overlapObj.unscaledPath);
      if (!areaLineIntersect.getBounds().isEmpty) {
        //laibungOverlaps.add(Wall.clone(borderSide));
      }
    }
    einkerbung.walls.removeLast();
    print("FOUND " + laibungOverlaps.length.toString() + " OVERLAPS");
  }
*/
  void calcAreaOverlap(List<Wall> lines) {
    Path areaIntersect = Path.combine(PathOperation.intersect, einkerbung.unscaledPath, overlapObj.unscaledPath);
    if (!areaIntersect.getBounds().isEmpty) {
      Rect area = areaIntersect.getBounds();
      List<Wall> walls = [
        Wall(angle: 0, length: 0, start: Corner.fromPoint(point: area.topLeft), end: Corner.fromPoint(point: area.topRight)),
        Wall(angle: 0, length: 0, start: Corner.fromPoint(point: area.topRight), end: Corner.fromPoint(point: area.bottomRight)),
        Wall(angle: 0, length: 0, start: Corner.fromPoint(point: area.bottomRight), end: Corner.fromPoint(point: area.bottomLeft)),
      ];
      flaeche = Flaeche(walls: walls);
    }
  }

  void calcWerkstofflinesInsideEinkerbung(List<Wall> lines) {
    for (Wall line in lines) {
      Path overlap = Path.combine(PathOperation.intersect, line.unscaledPath, einkerbung.unscaledPath);
      if (!overlap.getBounds().isEmpty) {
        if (overlap.getBounds().size.longestSide >= 0.1) {
          Wall laibungOverlap = calcLengthOfOverlap(Wall.clone(line));
          laibungOverlaps.add(Wall.clone(laibungOverlap));
        }
      }
    }
  }

  void calcBorderInsideWerkstoffarea() {
    einkerbung.walls.add(einkerbung.lastWall);
    for (Wall borderSide in einkerbung.walls) {
      Path overlap = Path.combine(PathOperation.intersect, borderSide.unscaledPath, overlapObj.unscaledPath);
      if (!overlap.getBounds().isEmpty) {
        if (overlap.getBounds().size.longestSide >= 0.1) {
          Wall laibungOverlap = calcLengthOfOverlap(Wall.clone(borderSide));
          laibungOverlaps.add(Wall.clone(laibungOverlap));
        }
      }
    }
    einkerbung.walls.removeLast();
  }

  Wall calcLengthOfOverlap(Wall input) {
    List<Corner> limits = [];

    for (Corner end in laibungIntersects) {
      if (input.unscaledPath.contains(end.point)) {
        limits.add(end);
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

  void paint(Canvas canvas) {
    for (Corner corner in laibungIntersects) {
      corner.paint(canvas, Colors.green, 10);
    }
    for (Wall wall in laibungOverlaps) {
      wall.paint(canvas, Colors.yellow, 5);
    }
    if (flaeche != null) {
      flaeche!.paint(canvas, Colors.red, 2.5);
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
}
