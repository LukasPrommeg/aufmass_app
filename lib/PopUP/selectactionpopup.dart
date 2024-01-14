import 'package:aufmass_app/Misc/actionselector.dart';
import 'package:flutter/material.dart';

class SelectActionPopup {
  String selected = "";

  Future<String> display(BuildContext context) async {
    ActionSelector selector = ActionSelector();
    selected = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wählen Sei eine Aktion'),
          content: selector,
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: const Text('Abbrechen'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    child: const Text('Weiter'),
                    onPressed: () {
                      if (selector.selected != "") {
                        selected = selector.selected;
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    return selected;
  }
}
