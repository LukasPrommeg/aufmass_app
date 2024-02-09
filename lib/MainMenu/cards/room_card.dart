import 'package:flutter/material.dart';
import 'package:aufmass_app/Hive/hive_operator.dart';
import 'package:aufmass_app/MainMenu/classes/Baustelle.dart';
import 'package:aufmass_app/MainMenu/classes/Room.dart';
import 'package:aufmass_app/MainMenu/dialogs/delete_dialog.dart';

import '../pages/room_page.dart';

class RoomCard extends StatefulWidget {
  final Room? room;

  const RoomCard(this.room, {super.key});

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
              widget.room!.name,
              style: const TextStyle(
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
        return const DeleteDialog(title: "Raum wirklich löschen");
      },
    );

    if (result != null && result) {
      await HiveOperator().deleteFromHive(widget.room!.key, "roomBox");

      Baustelle? b = await HiveOperator().getObjectFromHive(widget.room!.baustellenKey, "baustellenBox");

      // RELOAD [
      NavigatorState navigator = Navigator.of(context);

      // Push a new route while removing the previous route
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Rooms(),
          settings: RouteSettings(arguments: b!.key),
        ),
        (route) => false,
      );
      // ]
    }
  }
}
