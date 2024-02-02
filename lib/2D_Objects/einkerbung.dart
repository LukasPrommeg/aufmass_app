import 'dart:ui';
import 'package:aufmass_app/2D_Objects/flaeche.dart';
import 'package:aufmass_app/2D_Objects/wall.dart';
import 'package:aufmass_app/Misc/overlap.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:flutter/material.dart';

class Einkerbung extends Flaeche {
  String name;
  double tiefe;

  //temp
  List<DrawedWerkstoff> overlappingWerkstoffe = [];
  double scale = 0;
  Offset center = Offset.zero;

  Einkerbung({
    required this.name,
    required this.tiefe,
    required List<Wall> walls,
  }) : super(walls: walls);

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

    var paintYellow = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    int overlaps = 0;

    for (DrawedWerkstoff werkstoff in overlappingWerkstoffe) {
      Overlap overlap = Overlap(einkerbung: this, overlapObj: werkstoff.clickAble, werkstoff: werkstoff.werkstoff);
      overlap.initScale(scale, center);
      overlap.paint(canvas);
      /*List<Wall> lines = [];

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
      if (!areaIntersect.getBounds().isEmpty) {
        List<Offset> points = [];
        points.add(areaIntersect.getBounds().topLeft * scale - center);
        points.add(areaIntersect.getBounds().bottomRight * scale - center);
        canvas.drawPoints(PointMode.lines, points, paintGreen);
      }

      for (Wall line in lines) {
        walls.add(lastWall);
        walls.forEach((element) {
          Path lineIntersect = Path.combine(PathOperation.intersect, line.unscaledPath, element.unscaledPath);
          //print(intersection.getBounds());
          if (!lineIntersect.getBounds().isEmpty) {
            Offset diff = lineIntersect.getBounds().topLeft - lineIntersect.getBounds().bottomRight;

            if (diff.distance <= 0.1) {
              canvas.drawPoints(PointMode.points, [lineIntersect.getBounds().center * scale - center], paintRed);
            } else {
              List<Offset> points = [];
              points.add(lineIntersect.getBounds().topLeft * scale - center);
              points.add(lineIntersect.getBounds().bottomRight * scale - center);
              //canvas.drawPoints(PointMode.lines, points, paintBlue);
            }
            overlaps++;
            //laibungOverlaps[element.uuid]!.add(werkstoff.werkstoff);
          }
          Path areaLineIntersect = Path.combine(PathOperation.intersect, element.unscaledPath, werkstoff.clickAble.unscaledPath);
          if (!areaLineIntersect.getBounds().isEmpty) {
            List<Offset> points = [];
            points.add(areaLineIntersect.getBounds().topLeft * scale - center);
            points.add(areaLineIntersect.getBounds().bottomRight * scale - center);
            canvas.drawPoints(PointMode.lines, points, paintYellow);
          }
        });
        walls.removeLast();
      }*/
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
