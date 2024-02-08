import 'package:hive/hive.dart';

part 'Room.g.dart';

@HiveType(typeId: 1)
class Room extends HiveObject{
  @HiveField(0)
  String name;

  @HiveField(1)
  dynamic baustellenKey;

  Room(this.name, this.baustellenKey);
}