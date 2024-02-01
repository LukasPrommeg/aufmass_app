import 'dart:math';
import 'dart:ui';
import 'package:aufmass_app/2D_Objects/clickable.dart';
import 'package:aufmass_app/Einheiten/einheitcontroller.dart';
import 'package:aufmass_app/2D_Objects/corner.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/2D_Objects/wall.dart';

class Flaeche extends ClickAble {
  List<Wall> _walls = [];
  late Wall lastWall;
  Path areaPath = Path();
  double area = 0;

  List<Wall> get walls {
    return _walls;
  }

  Flaeche({
    required List<Wall> walls,
  }) : super(hbSize: 0) {
    _walls = walls;

    unscaledPath.moveTo(_walls.first.start.point.dx, _walls.first.start.point.dy);

    for (Wall wall in _walls) {
      unscaledPath.lineTo(wall.end.point.dx, wall.end.point.dy);
    }
    unscaledPath.close();

    calcSize();
    _calcLastWall();
  }

  Wall? detectClickedWall(Offset position) {
    _calcLastWall();
    if (lastWall.contains(position)) {
      return lastWall;
    }
    for (Wall wall in walls) {
      if (wall.contains(position)) {
        return wall;
      }
    }
    return null;
  }

  Corner? detectClickedCorner(Offset position) {
    if (lastWall.start.scaled != null && lastWall.start.contains(position)) {
      return lastWall.start;
    }
    for (Wall wall in walls) {
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
    for (Wall wall in walls) {
      if (wall.contains(position)) {
        return wall;
      }
    }
    if (lastWall.start.scaled != null && lastWall.start.contains(position)) {
      return lastWall.start;
    }
    for (Wall wall in walls) {
      if (wall.start.scaled != null && wall.start.contains(position)) {
        return wall.start;
      }
    }
    return null;
  }

  void calcSize() {
    size = Rect.zero;
    for (Wall wall in walls) {
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
    lastWall = Wall.fromStart(angle: 0, length: length, start: _walls.last.end);
    lastWall = Wall(angle: 0, length: length, start: walls.last.end, end: walls.first.start);
    lastWall.start.scaled = walls.last.end.scaled;
    lastWall.end.scaled = walls.first.start.scaled;

    lastWall.calcHitbox();
    lastWall.uuid = uuid;
  }

  @override
  void initScale(double scale, Offset center) {
    posBeschriftung = Offset.zero;
    area = 0;

    for (Wall wall in walls) {
      wall.initScale(scale, center);
    }

    areaPath = Path();
    areaPath.moveTo(walls.first.start.scaled!.dx, walls.first.start.scaled!.dy);

    _calcLastWall();

    walls.add(lastWall);

    for (int i = 0; i < walls.length; i++) {
      if (i == walls.length - 1) {
        area += walls[i].end.point.dx * (walls[0].end.point).dy;
        area -= walls[i].end.point.dy * (walls[0].end.point).dx;
      } else {
        area += walls[i].end.point.dx * (walls[i + 1].end.point).dy;
        area -= walls[i].end.point.dy * (walls[i + 1].end.point).dx;
        areaPath.lineTo(walls[i].end.scaled!.dx, walls[i].end.scaled!.dy);
      }
      posBeschriftung += walls[i].start.point;
    }
    posBeschriftung = (Offset(posBeschriftung.dx / (walls.length), posBeschriftung.dy / (walls.length)) * scale) - center;

    walls.removeLast();
    area = area.abs() / 2;
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
    for (Wall wall in _walls) {
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

    for (Wall wall in walls) {
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

  void paintCornerHB(Canvas canvas, [List<Corner>? hidden, Color? override]) {
    walls.add(lastWall);

    for (Wall wall in walls) {
      if (hidden != null && !hidden.contains(wall.start)) {
        wall.start.paintHB(canvas, override);
      }
    }
    walls.removeLast();
  }

  Corner? findCornerAtPoint(Offset position) {
    walls.add(lastWall);
    Corner? found;
    for (Wall wall in walls) {
      if (wall.start.point == position) {
        found = wall.start;
        break;
      }
    }
    walls.removeLast();

    return found;
  }

  List<Wall> findWallsAroundCorner(Corner corner) {
    List<Wall> around = [];
    if (walls.first.start == corner) {
      around.add(lastWall);
      around.add(walls.first);
      return around;
    }
    walls.add(lastWall);
    for (Wall wall in walls) {
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