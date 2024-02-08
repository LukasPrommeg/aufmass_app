import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:aufmass_app/Hive/HiveOperator.dart';
import 'package:aufmass_app/MainMenu/classes/Baustelle.dart';
import 'package:aufmass_app/MainMenu/classes/Room.dart';
import 'package:aufmass_app/MainMenu/dialogs/deleteDialog.dart';

import '../pages/roomPage.dart';

class RoomCard extends StatefulWidget {
  Room? _room;

  RoomCard(Room room) {
    super.key;
    this._room = room;
  }

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, "/planpage");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /*IconButton(
                onPressed: () {
                  _showDeleteDialog(context);
                },
                icon: Icon(Icons.delete)
            ),*/
            Text(
              widget._room!.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog("Raum wirklich löschen");
      },
    );

    if (result != null && result) {
      await HiveOperator().deleteFromHive(widget._room!.key, "roomBox");

      Baustelle? b = await HiveOperator().getObjectFromHive(widget._room!.baustellenKey, "baustellenBox");

      // RELOAD [
      NavigatorState navigator = Navigator.of(context);

      // Push a new route while removing the previous route
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Rooms(),
          settings: RouteSettings(arguments: b!.key),
        ),
            (route) => false,
      );
      // ]
    }
  }
}
