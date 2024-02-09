import 'package:aufmass_app/PlanPage/Room_Parts/room.dart';

//TODO: DB Speichern
class Projekt {
  String name;
  List<Room> rooms = [];

  Projekt({this.name = "unnamed", required this.rooms}) {
    if (rooms.isEmpty) {
      rooms.add(
        Room(name: "Raum 1"),
      );
    }
  }
}
