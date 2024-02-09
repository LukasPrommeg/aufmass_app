import 'package:flutter/material.dart';
import 'package:aufmass_app/MainMenu/classes/Baustelle.dart';

class BaustellenCard extends StatefulWidget {
  final Baustelle baustelle;

  const BaustellenCard(this.baustelle, {super.key});

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
          Navigator.pushReplacementNamed(context, "/rooms", arguments: widget.baustelle);
        },
        child: Column(
          children: [
            const Align(
              alignment: Alignment.center,
              child: Image(image: AssetImage("assets/eberl_logo.png")),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                widget.baustelle.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
