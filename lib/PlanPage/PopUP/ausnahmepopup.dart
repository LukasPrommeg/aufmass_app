import 'package:aufmass_app/PlanPage/Einheiten/einheitselector.dart';
import 'package:aufmass_app/PlanPage/Misc/alertinfo.dart';
import 'package:aufmass_app/PlanPage/Misc/lengthinput.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';

class AusnahmePopup {
  final einkerbungInitEvent = Event();

  double tiefe = double.infinity;
  String name = "Einkerbung";

  void finish() {
    tiefe = double.infinity;
    name = "Einkerbung";
  }

  Future<void> display(BuildContext context) async {
    EinheitSelector einheitSelector = EinheitSelector(setGlobal: false);
    TextEditingController nameInput = TextEditingController();
    LengthInput tiefenInput = LengthInput(
      hintText: "Tiefe der Einkerbung",
      maxText: "Keine Tiefe",
      drawingGrundflaeche: false,
      btnText: "Keine",
      useMaxValue: true,
    );

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Einkerbung einzeichnen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Einkerbung einstellen"),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: nameInput,
                  decoration: const InputDecoration(hintText: "Name der Einkerbung"),
                ),
                const SizedBox(
                  height: 10,
                ),
                einheitSelector,
                const SizedBox(
                  height: 10,
                ),
                tiefenInput,
                const SizedBox(
                  height: 10,
                ),
                const Text("Wählen Sie anschließend Ihren Ausgangspunkt!"),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.pop(context);
                finish();
              },
            ),
            ElevatedButton(
              child: const Text('Zeichnen'),
              onPressed: () {
                try {
                  if (tiefenInput.value != 0) {
                    tiefe = einheitSelector.convertToMM(tiefenInput.value);
                  }
                  if (nameInput.text.isNotEmpty) {
                    name = nameInput.text;
                  }
                  einkerbungInitEvent.broadcast();
                  Navigator.pop(context);
                } catch (e) {
                  AlertInfo().newAlert("Input wasn't a number");
                }
              },
            ),
          ],
        );
      },
    );
  }
}
