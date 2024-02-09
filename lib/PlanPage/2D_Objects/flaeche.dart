import 'dart:math';
import 'dart:ui';
import 'package:aufmass_app/PlanPage/2D_Objects/clickable.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitcontroller.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/linie.dart';

class Flaeche extends ClickAble {
  List<Linie> _walls = [];
  late Linie lastWall;
  Path areaPath = Path();
  double area = 0;

  List<Linie> get walls {
    return _walls;
  }

  Flaeche({
    required List<Linie> walls,
  }) : super(hbSize: 0) {
    _walls = walls;

    unscaledPath.moveTo(_walls.first.start.point.dx, _walls.first.start.point.dy);

    for (Linie wall in _walls) {
      unscaledPath.lineTo(wall.end.point.dx, wall.end.point.dy);
    }
    unscaledPath.close();

    calcSize();
    _calcLastWall();
    _calcArea();
  }

  Linie? detectClickedWall(Offset position) {
    _calcLastWall();
    if (lastWall.contains(position)) {
      return lastWall;
    }
    for (Linie wall in walls) {
      if (wall.contains(position)) {
        return wall;
      }
    }
    return null;
  }

  Punkt? detectClickedCorner(Offset position) {
    if (lastWall.start.scaled != null && lastWall.start.contains(position)) {
      return lastWall.start;
    }
    for (Linie wall in walls) {
      if (wall.start.scaled != null && wall.start.contains(position)) {
        return wall.start;
      }
    }
    return null;
  }

  ClickAble? detectClickedPart(Offset position) {
    if (lastWall.contains(position)) {
      return lastWall;
    }
    for (Linie wall in walls) {
      if (wall.contains(position)) {
        return wall;
      }
    }
    if (lastWall.start.scaled != null && lastWall.start.contains(position)) {
      return lastWall.start;
    }
    for (Linie wall in walls) {
      if (wall.start.scaled != null && wall.start.contains(position)) {
        return wall.start;
      }
    }
    return null;
  }

  void calcSize() {
    size = Rect.zero;
    for (Linie wall in walls) {
      size = size.expandToInclude(Rect.fromPoints(wall.end.point, wall.end.point));
    }
  }

  void _calcLastWall() {
    String uuid;
    try {
      uuid = lastWall.uuid;
    } catch (e) {
      uuid = UniqueKey().toString();
    }

    double length = sqrt((pow(_walls.last.end.point.dx - _walls.first.start.point.dx, 2) + pow(_walls.last.end.point.dy - _walls.first.start.point.dy, 2))).abs();
    lastWall = Linie.fromStart(angle: 0, length: length, start: _walls.last.end);
    lastWall = Linie(angle: 0, length: length, start: walls.last.end, end: walls.first.start);
    lastWall.start.scaled = walls.last.end.scaled;
    lastWall.end.scaled = walls.first.start.scaled;

    lastWall.calcHitbox();
    lastWall.uuid = uuid;
  }

  void _calcArea() {
    walls.add(lastWall);

    for (int i = 0; i < walls.length; i++) {
      if (i == walls.length - 1) {
        area += walls[i].end.point.dx * (walls[0].end.point).dy;
        area -= walls[i].end.point.dy * (walls[0].end.point).dx;
      } else {
        area += walls[i].end.point.dx * (walls[i + 1].end.point).dy;
        area -= walls[i].end.point.dy * (walls[i + 1].end.point).dx;
      }
    }
    area = area.abs() / 2;
    walls.removeLast();
  }

  @override
  void initScale(double scale, Offset center) {
    posBeschriftung = Offset.zero;
    area = 0;

    for (Linie wall in walls) {
      wall.initScale(scale, center);
    }

    areaPath = Path();
    areaPath.moveTo(walls.first.start.scaled!.dx, walls.first.start.scaled!.dy);

    _calcLastWall();

    _calcArea();

    walls.add(lastWall);

    for (int i = 0; i < walls.length; i++) {
      if (i != walls.length - 1) {
        areaPath.lineTo(walls[i].end.scaled!.dx, walls[i].end.scaled!.dy);
      }
      posBeschriftung += walls[i].start.point;
    }
    posBeschriftung = (Offset(posBeschriftung.dx / (walls.length), posBeschriftung.dy / (walls.length)) * scale) - center;

    walls.removeLast();
    areaPath.close();

    calcSize();
    super.initScale(scale, center);
  }

  @override
  void calcHitbox() {
    hitbox = areaPath;
  }

  @override
  void paint(Canvas canvas, Color color, double size, {bool debug = false}) {
    Paint paint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, paint);

    paintWalls(canvas, color, size, debug: debug);
  }

  void paintWalls(Canvas canvas, Color color, double size, {bool debug = false}) {
    walls.add(lastWall);
    for (Linie wall in _walls) {
      wall.paint(canvas, color, size);
      if (debug) {
        wall.start.paintHB(canvas);
        wall.paintHB(canvas);
      }
    }
    walls.removeLast();
  }

  @override
  void paintBeschriftung(Canvas canvas, Color color, String text, double size, {bool debug = false}) {
    Einheit selectedEinheit = EinheitController().selectedEinheit;

    TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );

    if (debug) {
      Paint paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      canvas.drawPoints(PointMode.points, [posBeschriftung], paint);
    }

    double displayArea = EinheitController().convertToSelectedSquared(area);

    final textSpan = TextSpan(
      text: "$text\nFLÄCHE: ${(displayArea).toStringAsFixed(2)} ${selectedEinheit.name}²",
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    textPainter.paint(canvas, posBeschriftung - Offset((textPainter.width / 2), textPainter.height / 2));
  }

  @override
  void paintLaengen(Canvas canvas, Color color, double size, {bool debug = false}) {
    Einheit selectedEinheit = EinheitController().selectedEinheit;

    TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );
    walls.add(lastWall);

    for (Linie wall in walls) {
      Offset centerLine = posBeschriftung + ((wall.end.scaled! + wall.start.scaled!) / 2) - posBeschriftung;

      if (debug) {
        Paint paint = Paint()
          ..color = Colors.red
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;
        canvas.drawPoints(PointMode.points, [centerLine], paint);
      }

      double diffx = wall.end.scaled!.dx - wall.start.scaled!.dx;
      double diffy = wall.end.scaled!.dy - wall.start.scaled!.dy;

      double angle = atan(diffy / diffx);

      Offset posMark = centerLine;
      Offset offset = Offset.fromDirection(angle + (pi / 2), size);

      if (!areaPath.contains(posMark + offset)) {
        posMark += offset;
      } else {
        posMark -= offset;
      }

      canvas.save();
      canvas.translate(posMark.dx, posMark.dy);

      canvas.rotate(angle);
      canvas.translate(-posMark.dx, -posMark.dy);

      double displayLength = EinheitController().convertToSelected(wall.length);

      final textSpan = TextSpan(
        text: "${(displayLength).toStringAsFixed(2)} ${selectedEinheit.name}",
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
    walls.removeLast();
  }

  void paintCornerHB(Canvas canvas, [List<Punkt>? hidden, Color? override]) {
    walls.add(lastWall);

    for (Linie wall in walls) {
      if (hidden != null && !hidden.contains(wall.start)) {
        wall.start.paintHB(canvas, override);
      }
    }
    walls.removeLast();
  }

  Punkt? findCornerAtPoint(Offset position) {
    walls.add(lastWall);
    Punkt? found;
    for (Linie wall in walls) {
      if (wall.start.point == position) {
        found = wall.start;
        break;
      }
    }
    walls.removeLast();

    return found;
  }

  List<Linie> findWallsAroundCorner(Punkt corner) {
    List<Linie> around = [];
    if (walls.first.start == corner) {
      around.add(lastWall);
      around.add(walls.first);
      return around;
    }
    walls.add(lastWall);
    for (Linie wall in walls) {
      if (wall.start == corner) {
        around.add(wall);
      } else if (wall.end == corner) {
        around.add(wall);
      }
    }
    walls.removeLast();
    return around;
  }
}
