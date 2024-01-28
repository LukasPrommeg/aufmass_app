import 'dart:math';
import 'dart:ui';
import 'package:aufmass_app/2D_Objects/einkerbung.dart';
import 'package:aufmass_app/2D_Objects/corner.dart';
import 'package:aufmass_app/2D_Objects/flaeche.dart';
import 'package:aufmass_app/2D_Objects/wall.dart';
import 'package:flutter/material.dart';

class Grundflaeche extends Flaeche {
  String raumName;
  Color color = Colors.black;
  final List<Einkerbung> _einkerbungen = [];
  bool hasBeschriftung;
  bool hasLaengen;
  double drawSize;
  double textSize;
  double laengenSize;

  Grundflaeche({
    required this.raumName,
    required List<Wall> walls,
    this.hasBeschriftung = true,
    this.hasLaengen = true,
    this.drawSize = 5,
    this.textSize = 15,
    this.laengenSize = 15,
  }) : super(walls: walls);

  void addEinkerbung(Einkerbung newEinkerbung) {
    _einkerbungen.add(newEinkerbung);
  }

  void removeEinkerbung(Einkerbung einkerbung) {
    _einkerbungen.remove(einkerbung);
  }

  @override
  void initScale(double scale, Offset center) {
    super.initScale(scale, center);

    for (Einkerbung einkerbung in _einkerbungen) {
      einkerbung.initScale(scale, center);
    }
  }

  void paintGrundflaeche(Canvas canvas) {
    Path temp = super.areaPath;
    for (Einkerbung einkerbung in _einkerbungen) {
      areaPath = Path.combine(PathOperation.difference, super.areaPath, einkerbung.areaPath);

      einkerbung.paintWalls(canvas, color, 1);
    }
    super.paint(canvas, color, drawSize);
    if (hasBeschriftung) {
      super.paintBeschriftung(canvas, color, raumName, textSize);
    }
    if (hasLaengen) {
      super.paintLaengen(canvas, color, laengenSize);
    }
    super.areaPath = temp;
  }

  bool containsFullWall(Wall wall) {
    Path wallPath = Path();
    wallPath.moveTo(wall.start.point.dx, wall.start.point.dy);
    wallPath.lineTo(wall.end.point.dx, wall.end.point.dy);

    bool contains = true;
    PathMetrics pathMetrics = wallPath.computeMetrics();

    pathMetrics.toList().forEach((element) {
      for (var i = 0; i < element.length; i++) {
        Tangent? tangent = element.getTangentForOffset(i.toDouble());
        if (tangent != null) {
          Offset pos = Offset(tangent.position.dx.roundToDouble(), tangent.position.dy.roundToDouble());
          if (!unscaledPath.contains(pos)) {
            contains = false;
            break;
          }
        }
      }
    });

    return contains;
  }

  Future<double> findMaxLength(Corner startingPoint, double angle) async {
    List<double> stepLengths = [10000, 5000, 1000, 500, 100, 50, 10, 5, 1, 0.5, 0.1, 0.75, 0.5, 0.25, 0.1, 0.075, 0.05, 0.025, 0.01, 0.0075, 0.005, 0.0025, 0.001];

    double length = 0;
    Offset einheitsVektor = Offset.fromDirection((angle - 90) * pi / 180, stepLengths.first);
    Offset origin = startingPoint.point;

    int iterations = 0;

    for (double step in stepLengths) {
      await Future<void>.delayed(const Duration(milliseconds: 10));

      einheitsVektor = Offset.fromDirection((angle - 90) * pi / 180, step);

      Offset next = origin + einheitsVektor;

      while (unscaledPath.contains(next)) {
        origin = next;
        length += step;
        next += einheitsVektor;
        iterations++;
      }
    }

    print(iterations.toString() + "-" + length.toString());

    return double.parse(length.toStringAsFixed(2));
  }
}
