import 'package:aufmass_app/Paint/paintcontroller.dart';
import 'package:aufmass_app/Room_Parts/room_wall.dart';
import 'package:aufmass_app/paint/drawing_zone.dart';

class Room {
  String name;
  late DrawingZone drawingZone;
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
