import 'package:aufmass_app/PlanPage/Room_Parts/room_part.dart';
import 'package:aufmass_app/PlanPage/Room_Parts/room_wall.dart';

//TODO: DB Speichern
class Room extends RoomPart {
  final Map<String, RoomWall> _walls = <String, RoomWall>{};

  Map<String, RoomWall> get walls {
    return _walls;
  }

  Room({
    required String name,
  }) : super(name: name) {
    paintController.grundFlaeche = grundflaeche;
  }
}
