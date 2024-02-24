import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff_controller.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';

class WerkstoffInputPopup {
  Werkstoff? selectedWerkstoff = Werkstoff(name: "", color: Colors.black, typ: WerkstoffTyp.stk);
  final selectedWerkstoffEvent = Event();

  void finish() {
    selectedWerkstoff = null;
  }

  Future<void> display(BuildContext context) async {
    final List<DropdownMenuEntry<Werkstoff>> dropdownList = [];

    for (Werkstoff werkstoff in WerkstoffController().werkstoffe) {
      if (werkstoff.typ != WerkstoffTyp.stk) {
        dropdownList.add(DropdownMenuEntry<Werkstoff>(value: werkstoff, label: werkstoff.name));
      }
    }
    selectedWerkstoff = dropdownList.first.value;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Werkstoff einzeichnen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Wählen Sie einen Werkstoff:"),
                const SizedBox(
                  height: 10,
                ),
                DropdownMenu<Werkstoff>(
                  initialSelection: selectedWerkstoff,
                  dropdownMenuEntries: dropdownList,
                  onSelected: (value) {
                    selectedWerkstoff = value;
                  },
                ),
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
                selectedWerkstoffEvent.broadcast();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
