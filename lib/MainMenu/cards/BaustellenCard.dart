import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:aufmass_app/Hive/HiveOperator.dart';
import 'package:aufmass_app/MainMenu/classes/Baustelle.dart';
import 'package:aufmass_app/MainMenu/dialogs/TextInputDialog.dart';
import 'package:aufmass_app/MainMenu/dialogs/deleteDialog.dart';
import 'package:aufmass_app/MainMenu/pages/homePage.dart';

class BaustellenCard extends StatefulWidget {
  late Baustelle _baustelle;

  BaustellenCard(Baustelle baustelle) {
    super.key;
    this._baustelle = baustelle;
  }

  @override
  State<BaustellenCard> createState() => _BaustellenCardState();
}

class _BaustellenCardState extends State<BaustellenCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, "/rooms", arguments: widget._baustelle);
        },
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Image(image: AssetImage("assets/eberl_logo.png")),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                widget._baustelle.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ]
        )
      )
    );
  }
}
