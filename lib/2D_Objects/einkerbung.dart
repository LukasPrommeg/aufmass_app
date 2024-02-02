import 'dart:ui';
import 'package:aufmass_app/2D_Objects/flaeche.dart';
import 'package:aufmass_app/2D_Objects/wall.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:flutter/material.dart';

class Einkerbung extends Flaeche {
  String name;
  double tiefe;
  Map<String, List<Werkstoff>> laibungOverlaps = <String, List<Werkstoff>>{};

  //temp
  List<DrawedWerkstoff> overlappingWerkstoffe = [];
  double scale = 0;
  Offset center = Offset.zero;

  Einkerbung({
    required this.name,
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

    int overlaps = 0;

    for (DrawedWerkstoff werkstoff in overlappingWerkstoffe) {
      List<Wall> lines;

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

      Path areaIntersect = Path.combine(PathOperation.intersect, unscaledPath, werkstoff.clickAble.unscaledPath);
      print(areaIntersect.getBounds());
      canvas.drawPath(areaIntersect, paintGreen);
      List<Offset> points = [];
      points.add(areaIntersect.getBounds().topLeft * scale - center);
      points.add(areaIntersect.getBounds().bottomRight * scale - center);
      canvas.drawPoints(PointMode.lines, points, paintGreen);

      for (Wall line in lines) {
        walls.add(lastWall);
        walls.forEach((element) {
          Path intersection = Path.combine(PathOperation.intersect, line.unscaledPath, element.unscaledPath);
          //print(intersection.getBounds());
          if (!intersection.getBounds().isEmpty) {
            Offset diff = intersection.getBounds().topLeft - intersection.getBounds().bottomRight;
            if (diff.distance >= 1) {
              List<Offset> points = [];
              points.add(intersection.getBounds().topLeft * scale - center);
              points.add(intersection.getBounds().bottomRight * scale - center);
              canvas.drawPoints(PointMode.lines, points, paintBlue);
            } else {
              canvas.drawPoints(PointMode.points, [intersection.getBounds().center * scale - center], paintRed);
            }

            overlaps++;
            //laibungOverlaps[element.uuid]!.add(werkstoff.werkstoff);
          }
        });
        walls.removeLast();
      }
    }
    print("THERE ARE " + overlaps.toString() + " OVERLAPTS");
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
