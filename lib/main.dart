import 'package:aufmass_app/Hive/hive_operator.dart';
import 'package:aufmass_app/MainMenu/classes/Baustelle.dart';
import 'package:aufmass_app/MainMenu/classes/Room.dart';
import 'package:aufmass_app/MainMenu/pages/home_page.dart';
import 'package:aufmass_app/MainMenu/pages/room_page.dart';
import 'package:aufmass_app/PlanPage/projekt.dart';
// ignore: unused_import
import 'package:dcdg/dcdg.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/planpage.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  /*INITIALIZE HIVE [
  // Get the application documents directory
  //final Directory appDocDir = await getApplicationDocumentsDirectory();

  //Define the subdirectory where you want to store your Hive box files
  //final String hiveBoxPath = appDocDir.path + '/HiveBoxes';
  //print(hiveBoxPath);*/

  await Hive.initFlutter();
  Hive.registerAdapter(BaustelleAdapter());
  Hive.registerAdapter(RoomAdapter());
  await Hive.openBox<Baustelle>(HiveOperator().baustellenBoxString, path: HiveOperator().path);
  await Hive.openBox<Room>(HiveOperator().roomBoxString, path: HiveOperator().path);

  // ]

  runApp(const Controller());
}

class Controller extends StatelessWidget {
  const Controller({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fliesenleger",
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: "/planpage",
      routes: {
        "/home": (context) => const Home(),
        "/rooms": (context) => const Rooms(),
        "/planpage": (context) => PlanPage(
              projekt: Projekt(
                rooms: [],
              ),
            ),
      },
    );
  }
}
