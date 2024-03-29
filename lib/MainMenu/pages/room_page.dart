import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aufmass_app/Hive/hive_operator.dart';
import 'package:aufmass_app/MainMenu/classes/Baustelle.dart';
import 'package:aufmass_app/MainMenu/classes/Room.dart';
import 'package:aufmass_app/MainMenu/cards/room_card.dart';
import 'package:aufmass_app/MainMenu/dialogs/delete_dialog.dart';
import 'package:aufmass_app/MainMenu/dialogs/textinput_dialog.dart';
import 'package:aufmass_app/MainMenu/pages/home_page.dart';

class Rooms extends StatefulWidget {
  const Rooms({super.key});

  @override
  State<Rooms> createState() => _RoomsState();
}

class _RoomsState extends State<Rooms> {
  List<Room> _rooms = [];
  dynamic _baustellenKey;
  String _baustellenName = "";
  late Baustelle _superBaustelle;

  @override
  Widget build(BuildContext context) {
    _superBaustelle = ModalRoute.of(context)!.settings.arguments as Baustelle;
    _baustellenName = _superBaustelle.name;
    _baustellenKey = _superBaustelle.key;

    return FutureBuilder<List<Room>>(
      future: HiveOperator().getListFromHive(HiveOperator().roomBoxString),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Room> temp = [];
          for (Room r in snapshot.data!) {
            if (r.baustellenKey == _baustellenKey) {
              temp.add(r);
            }
          }
          _rooms = temp;

          return Scaffold(
            appBar: AppBar(
              title: Text(_baustellenName),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/home");
                },
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    _showPutDialog(context);
                  },
                  icon: const Icon(Icons.create),
                ),
                IconButton(
                  onPressed: () {
                    _showDeleteDialog(context);
                  },
                  icon: const Icon(Icons.delete),
                  color: Colors.blue,
                ),
              ],
            ),
            body: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 5,
              children: List<Widget>.generate(_rooms.length, (int index) {
                return RoomCard(_rooms[index]);
              }),
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                _showAddDialog(context);
              },
            ),
          );
        }
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const TextInputDialog("Raum hinzufügen", "Bitte Raumnamen eingeben");
      },
    );

    if (result != null) {
      Room r = Room(result, _baustellenKey);
      await HiveOperator().addToHive(r, HiveOperator().roomBoxString);

      List<Room> temp = [];
      List<Room> boxRooms = await HiveOperator().getListFromHive(HiveOperator().roomBoxString);

      setState(() {
        for (Room r in boxRooms) {
          if (r.baustellenKey == _baustellenKey) {
            temp.add(r);
          }
        }

        _rooms = temp;
      });
    }
  }

  Future<void> _showPutDialog(BuildContext context) async {
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const TextInputDialog("Baustellenname ändern", "Bitte Baustellenname eingeben");
      },
    );

    if (result != null) {
      Baustelle b = Baustelle(result);
      await HiveOperator().changeInHive(b, _superBaustelle.key, "baustellenBox");

      //RELOAD [
      // Get the current navigator's state
      NavigatorState navigator = Navigator.of(context);

      // Push a new route while removing the previous route
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
        (route) => false,
      );
      // ]
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const DeleteDialog(title: "Baustelle löschen");
      },
    );

    if (result != null && result) {
      await HiveOperator().deleteFromHive(_superBaustelle.key, HiveOperator().baustellenBoxString);
      //Um alle Räume mit dem gelöschten BaustellenKey zu löschen
      await HiveOperator().deleteAllObjectsWithKeyFromHive(_superBaustelle.key, HiveOperator().roomBoxString);

      //TODO context.setState() ausprobieren
      //RELOAD [
      // Get the current navigator's state
      NavigatorState navigator = Navigator.of(context);

      // Push a new route while removing the previous route
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
        (route) => false,
      );
      // ]
    }
  }
}
