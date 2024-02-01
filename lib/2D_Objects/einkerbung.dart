import 'dart:ui';

import 'package:aufmass_app/2D_Objects/flaeche.dart';
import 'package:aufmass_app/2D_Objects/wall.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:flutter/material.dart';

class Einkerbung extends Flaeche {
  double tiefe;
  Map<String, List<Werkstoff>> laibungOverlaps = <String, List<Werkstoff>>{};

  //temp
  List<DrawedWerkstoff> overlappingWerkstoffe = [];
  double scale = 0;
  Offset center = Offset.zero;

  Einkerbung({
    required this.tiefe,
    required List<Wall> walls,
  }) : super(walls: walls) {
    walls.add(lastWall);
    for (Wall wall in this.walls) {
      laibungOverlaps[wall.uuid] = [];
    }
    walls.removeLast();
  }

  void paintIntersects(Canvas canvas) {
    var paintGreen = Paint()
      ..color = Colors.green
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    var paintRed = Paint()
      ..color = Colors.red
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    var paintBlue = Paint()
      ..color = Colors.blue
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    for (DrawedWerkstoff werkstoff in overlappingWerkstoffe) {
      List<Wall> lines;

      switch (werkstoff.werkstoff.typ) {
        case WerkstoffTyp.flaeche:
          lines = (werkstoff.clickAble as Flaeche).walls;
          lines.add((werkstoff.clickAble as Flaeche).lastWall);
          break;
        case WerkstoffTyp.linie:
          lines = [(werkstoff.clickAble as Wall)];
          break;
        default:
          return;
      }

      for (Wall line in lines) {
        walls.add(lastWall);
        walls.forEach((element) {
          Path intersection = Path.combine(PathOperation.intersect, line.unscaledPath, element.unscaledPath);
          //print(intersection.getBounds());
          if (!intersection.getBounds().isEmpty) {
            print("OVERLAPPING");
            canvas.drawPoints(PointMode.points, [intersection.getBounds().center * scale - center], paintRed);
            //laibungOverlaps[element.uuid]!.add(werkstoff.werkstoff);
          }
        });
        walls.removeLast();
      }
    }
  }

  @override
  void initScale(double scale, Offset center) {
    this.scale = scale;
    this.center = center;
    super.initScale(scale, center);
  }

  void findOverlap(List<DrawedWerkstoff> werkstoffe) {
    this.overlappingWerkstoffe.addAll(werkstoffe);
  }
}
