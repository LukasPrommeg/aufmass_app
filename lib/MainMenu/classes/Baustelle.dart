import 'package:hive_flutter/hive_flutter.dart';
import 'package:aufmass_app/MainMenu//classes/Room.dart';

part 'Baustelle.g.dart';
//Befehl zum Akturalisieren flutter pub run build_runner build

@HiveType(typeId: 0)
class Baustelle extends HiveObject {
  @HiveField(0)
  String name;

  /*@HiveField(1)
  List<Room> rooms = [];*/

  Baustelle(this.name);
}