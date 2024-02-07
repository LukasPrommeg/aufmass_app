import 'package:aufmass_app/PlanPage/Paint/paintcontroller.dart';
import 'package:aufmass_app/PlanPage/Room_Parts/room_wall.dart';
import 'package:aufmass_app/PlanPage/paint/drawing_zone.dart';

//TODO: DB Speichern
class Room {
  String name;
  late DrawingZone drawingZone; //nicht speichern
  final PaintController paintController;
  final Map<String, RoomWall> _walls = <String, RoomWall>{};

  Map<String, RoomWall> get walls {
    return _walls;
  }

  Room({
    required this.name,
    required this.paintController,
  }) {
    paintController.roomName = name;
    drawingZone = DrawingZone(paintController: paintController);
  }
}
