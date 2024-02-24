import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/grundflaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/linie.dart';
import 'package:aufmass_app/PlanPage/Room_Parts/room_part.dart';
import 'package:flutter/material.dart';

//TODO: DB Speichern
class RoomWall extends RoomPart {
  final Linie baseLine;
  final double height;

  RoomWall({
    required this.baseLine,
    required this.height,
    required name,
  }) : super(name: name) {
    List<Linie> walls = [];

    walls.add(Linie.fromStart(angle: 90, length: baseLine.length, start: Punkt.fromPoint(point: Offset.zero)));
    walls.add(Linie.fromStart(angle: 180, length: height, start: walls.last.end));
    walls.add(Linie.fromStart(angle: 270, length: baseLine.length, start: walls.last.end));

    grundflaeche = Grundflaeche(raumName: name, walls: walls);
    paintController.grundFlaeche = grundflaeche;
    paintController.reset();
  }
}
