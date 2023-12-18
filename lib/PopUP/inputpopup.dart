import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/CircleSlider/circleslider.dart';
import 'package:event/event.dart';
import 'package:flutter_test_diplom/Misc/einheitselector.dart';
import 'package:flutter_test_diplom/drawing_page/paint/wall.dart';

class InputPopup {
  final TextEditingController _textFieldController = TextEditingController();

  final double sliderRange;
  final addWallEvent = Event<Wall>();
  late CircleSlider slider;

  //TODO: Zuletzt gewählte Einheit in DB speichern

  InputPopup({
    this.sliderRange = 300,
  }) {
    init(0, true);
  }

  void init(double lastWallAngle, bool isFirstWall) {
    _textFieldController.text = "";
    slider = CircleSlider(
      radius: 75,
      centerAngle: lastWallAngle,
      maxAngle: sliderRange / 2,
      hitboxSize: 0.1,
      isFirstWall: isFirstWall,
    );
  }

  Future<void> displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Wand hinzufügen'),
            content: SizedBox(
              height: 320,
              child: Column(
                children: [
                  TextField(
                    controller: _textFieldController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(hintText: "Länge der Wand"),
                  ),
                  SizedBox(height: 10),
                  EinheitSelector(),
                  const SizedBox(
                    height: 40,
                    width: 150,
                    child: Stack(alignment: Alignment.bottomLeft, children: [
                      Text(
                        'Winkel: ',
                        style: TextStyle(
                            color: Color.fromARGB(255, 90, 90, 90),
                            decoration: TextDecoration.underline),
                        textAlign: TextAlign.center,
                      ),
                    ]),
                  ),
                  slider,
                ],
              ),
            ),
            actions: <Widget>[
              /*
              ElevatedButton(
                child: const Text('X'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),*/
              ElevatedButton(
                child: const Text('Fertigstellen'),
                onPressed: () {
                  addWallEvent.broadcast();
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('Zeichnen'),
                onPressed: () {
                  try {
                    double length = double.parse(_textFieldController.text);

                    double angle = slider.centerAngle;
                    angle += -slider.value;
                    addWallEvent.broadcast(Wall(angle: angle, length: length));
                    Navigator.pop(context);
                  } catch (e) {
                    //TODO: Fehler bei der Eingabe
                  }
                },
              ),
              /*MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text('Finish'),
                onPressed: () {
                  addWallEvent.broadcast();
                  Navigator.pop(context);
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () {
                  try {
                    double length = double.parse(_textFieldController.text);

                    double angle = slider.centerAngle;
                    angle += -slider.value;
                    addWallEvent.broadcast(Wall(angle: angle, length: length));
                    Navigator.pop(context);
                  } catch (e) {
                    //TODO: Fehler bei der Eingabe
                  }
                },
              ),*/
            ],
          );
        });
  }
}
