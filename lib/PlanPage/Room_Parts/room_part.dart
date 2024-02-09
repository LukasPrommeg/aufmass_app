import 'package:aufmass_app/PlanPage/2D_Objects/grundflaeche.dart';
import 'package:aufmass_app/PlanPage/Paint/paintcontroller.dart';
import 'package:aufmass_app/PlanPage/paint/drawing_zone.dart';
import 'package:flutter/material.dart';

//TODO: DB Speichern
abstract class RoomPart {
  String _name;
  @protected
  Grundflaeche? grundflaeche;

  @protected
  final PaintController _paintController = PaintController(); //nicht speichern
  @protected
  late DrawingZone _drawingZone; //nicht speichern

  String get name {
    return _name;
  }

  set name(String name) {
    _name = name;
    _paintController.flaechenName = name;
  }

  PaintController get paintController {
    return _paintController;
  }

  RoomPart({required String name}) : _name = name {
    _paintController.flaechenName = _name;
    _drawingZone = DrawingZone(paintController: _paintController);
  }

  Widget drawRoomPart() {
    return _drawingZone;
  }
}
