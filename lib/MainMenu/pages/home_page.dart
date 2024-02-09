import 'package:flutter/material.dart';
import 'package:aufmass_app/Hive/hive_operator.dart';
import 'package:aufmass_app/MainMenu/cards/baustellen_card.dart';
import 'package:aufmass_app/MainMenu/dialogs/textinput_dialog.dart';
import 'package:aufmass_app/MainMenu/classes/Baustelle.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Baustelle> _baustellen = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Baustelle>>(
      future: HiveOperator().getListFromHive(HiveOperator().baustellenBoxString),
      builder: (context, snapshot) {
        //Hive Connection Überprüfung
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          _baustellen = snapshot.data ?? [];

          return Scaffold(
            appBar: AppBar(
              title: const Text("Baustellen"),
            ),
            body: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 5,
              children: List<Widget>.generate(_baustellen.length, (int index) {
                return BaustellenCard(_baustellen[index]);
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
        return const TextInputDialog("Baustelle Hinzufügen", "Bitte Baustellenname eingeben");
      },
    );

    if (result != null) {
      Baustelle b = Baustelle(result);
      await HiveOperator().addToHive(b, HiveOperator().baustellenBoxString);

      List<Baustelle> baustellen = await HiveOperator().getListFromHive(HiveOperator().baustellenBoxString);

      setState(() {
        _baustellen = baustellen;
      });
    }
  }
}
