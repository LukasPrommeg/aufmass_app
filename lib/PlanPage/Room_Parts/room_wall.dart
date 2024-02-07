import 'package:aufmass_app/PlanPage/2D_Objects/corner.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/grundflaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/wall.dart';
import 'package:aufmass_app/PlanPage/Paint/drawing_zone.dart';
import 'package:aufmass_app/PlanPage/Paint/paintcontroller.dart';
import 'package:flutter/material.dart';

class RoomWall {
  final Wall wall;
  final double height;
  final String name;
  final PaintController paintController;
  late DrawingZone drawingZone;

  RoomWall({
    required this.wall,
    required this.height,
    required this.name,
    required this.paintController,
  }) {
    paintController.roomName = name;

    List<Wall> walls = [];

    walls.add(Wall.fromStart(
        angle: 90,
        length: wall.length,
        start: Corner.fromPoint(point: Offset.zero)));
    walls
        .add(Wall.fromStart(angle: 180, length: height, start: walls.last.end));
    walls.add(
        Wall.fromStart(angle: 270, length: wall.length, start: walls.last.end));

    paintController.grundFlaeche = Grundflaeche(raumName: name, walls: walls);

    drawingZone = DrawingZone(paintController: paintController);
  }
}
