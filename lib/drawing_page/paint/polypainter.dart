import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/flaeche.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';
import 'package:flutter_test_diplom/drawing_page/paint/wall.dart';

class PolyPainter extends CustomPainter {
  PolyPainter({required Listenable repaint}) : super(repaint: repaint);
  List<Flaeche> _flaechen = [];

  void drawFlaechen(List<Flaeche> newFlaechen) {
    _flaechen = List.from(newFlaechen);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (Flaeche flaeche in _flaechen) {
      Paint paint = Paint()
        ..color = flaeche.color.withOpacity(0.25)
        ..style = PaintingStyle.fill;
      canvas.drawPath(flaeche.path, paint);

      paint = Paint()
        ..color = flaeche.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawPath(flaeche.path, paint);

      if (flaeche.hasBeschriftung) {
        const textStyle = TextStyle(
          color: Colors.black,
          fontSize: 10,
        );
        paint = Paint()
          ..color = Colors.red
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

        canvas.drawPoints(PointMode.points, [flaeche.posBeschriftung], paint);

        double displayArea = flaeche.area;

        switch (PaintController().selectedEinheit) {
          case Einheit.m:
            displayArea /= 1000000;
            break;
          case Einheit.cm:
            displayArea /= 100;
            break;
          default:
            break;
        }

        final textSpan = TextSpan(
          text:
              "${flaeche.name}\nFLÄCHE: ${(displayArea).toStringAsFixed(2)} ${PaintController().selectedEinheit.name}²",
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        textPainter.paint(
            canvas,
            flaeche.posBeschriftung -
                Offset((textPainter.width / 2), textPainter.height / 2));

        flaeche.walls.add(Wall(angle: 0, length: 0));
        Offset end = Offset.zero;

        for (Wall wall in flaeche.walls) {
          if (wall == flaeche.walls.last) {
            double length = sqrt((pow(end.dx, 2) + pow(end.dy, 2)));
            wall = Wall(angle: 0, length: length);
            wall.scaledStart = flaeche.walls[flaeche.walls.length - 2].scaledEnd;
            wall.scaledEnd = flaeche.walls.first.scaledStart;
          }

          end += wall.end;

          Offset center =
              (wall.scaledEnd!.center + wall.scaledStart!.center) / 2;

          Offset diffFromAreaCenter = center - flaeche.posBeschriftung;

          Offset centerLine = flaeche.posBeschriftung + diffFromAreaCenter;

          canvas.drawPoints(PointMode.points, [centerLine], paint);

          double diffx =
              wall.scaledEnd!.center.dx - wall.scaledStart!.center.dx;
          double diffy =
              wall.scaledEnd!.center.dy - wall.scaledStart!.center.dy;

          double angle = atan(diffy / diffx);

          Offset posMark = centerLine;
          Offset offset = Offset.fromDirection(angle + (pi / 2), 15);

          if (!flaeche.path.contains(posMark + offset)) {
            posMark += offset;
          } else {
            posMark -= offset;
          }

          canvas.save();
          canvas.translate(posMark.dx, posMark.dy);

          canvas.rotate(angle);
          canvas.translate(-posMark.dx, -posMark.dy);

          double displayLength = wall.length;
          switch (PaintController().selectedEinheit) {
            case Einheit.m:
              displayLength /= 1000;
              break;
            case Einheit.cm:
              displayLength /= 10;
              break;
            default:
              break;
          }

          final textSpan = TextSpan(
            text:
                "${(displayLength).toStringAsFixed(2)} ${PaintController().selectedEinheit.name}",
            style: textStyle,
          );
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          posMark -= Offset((textPainter.width / 2), textPainter.height * 0.5);

          textPainter.paint(canvas, posMark);

          canvas.restore();
        }
        flaeche.walls.removeLast();
      }
    }
  }

  void rotateAndPrint(Canvas canvas, Offset pos, String text) {}

  @override
  bool shouldRepaint(PolyPainter oldDelegate) {
    return true;
  }
}
