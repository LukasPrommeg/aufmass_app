import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/flaeche.dart';
import 'dart:math';

class PolyPainter extends CustomPainter {
  List<Flaeche> flaechen = [];
  double scale = 1;

  void drawFlaechen(List<Flaeche> newFlaechen) {
    flaechen = List.from(newFlaechen);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (Flaeche flaeche in flaechen) {
      Paint paint = Paint()
        ..color = flaeche.color.withOpacity(0.25)
        ..style = PaintingStyle.fill;
      canvas.drawPath(flaeche.path, paint);

      paint = Paint()
        ..color = flaeche.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawPath(flaeche.path, paint);

      const textStyle = TextStyle(
        color: Colors.black,
        fontSize: 10,
      );

      paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawPoints(PointMode.points, [flaeche.center], paint);

      //calculateP
      //canvas.drawRect(flaeche.path.getBounds(), paint);

      final textSpan = TextSpan(
        text: flaeche.name +
            "\nFLÄCHE: " +
            (flaeche.area / scale / 100).toStringAsFixed(2) +
            "mm²",
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      textPainter.paint(
          canvas,
          flaeche.center -
              Offset((textPainter.width / 2), textPainter.height / 2));

      //TODO: qm der Fläche statt Punkt anzeigen

      List<Offset> areaWithEnd = List.from(flaeche.corners);
      areaWithEnd.add(flaeche.corners.first);
      for (int i = 0; i < areaWithEnd.length - 1; i++) {
        Offset center = (areaWithEnd[i + 1] + areaWithEnd[i]) / 2;
        canvas.drawPoints(PointMode.points, [center], paint);

        //TODO: m der Linie statt Punkt anzeigen
        canvas.save();
        canvas.translate(center.dx, center.dy);

        double diffx = areaWithEnd[i + 1].dx - areaWithEnd[i].dx;
        double diffy = areaWithEnd[i + 1].dy - areaWithEnd[i].dy;

        double angle = atan(diffy / diffx);

        canvas.rotate(angle);
        canvas.translate(-center.dx, -center.dy);

        final textSpan = TextSpan(
          text: (flaeche.lengths[i] / scale).toStringAsFixed(2) + "mm",
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        if (angle > 0 && center.dx < flaeche.center.dx) {
          center -= Offset((textPainter.width / 2), textPainter.height * -0.5);
        } else if (angle < 0 && center.dx > flaeche.center.dx) {
          center -= Offset((textPainter.width / 2), textPainter.height * -0.5);
        } else {
          center -= Offset((textPainter.width / 2), textPainter.height * 1.5);
        }
        textPainter.paint(canvas, center);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(PolyPainter oldDelegate) {
    return true;
  }
}
