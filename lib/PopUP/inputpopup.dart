import 'package:aufmass_app/drawing_page/paint/corner.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/CircleSlider/circleslider.dart';
import 'package:event/event.dart';
import 'package:aufmass_app/Misc/einheitcontroller.dart';
import 'package:aufmass_app/Misc/einheitselector.dart';
import 'package:aufmass_app/drawing_page/paint/wall.dart';

class InputPopup {
  final TextEditingController _textFieldController = TextEditingController();

  final double sliderRange;
  final addWallEvent = Event<Wall>();
  late EinheitSelector einheitSelector = EinheitSelector(
    setGlobal: false,
  );
  late CircleSlider slider;

  //TODO: Zuletzt gewählte Einheit in DB speichern

  InputPopup({
    this.sliderRange = 300,
  }) {
    init(0, true);
  }

  void init(double lastWallAngle, bool isFirstWall) {
    _textFieldController.text = "";
    einheitSelector = EinheitSelector(
      setGlobal: false,
    );
    slider = CircleSlider(
      radius: 75,
      centerAngle: lastWallAngle,
      maxAngle: sliderRange / 2,
      hitboxSize: 0.1,
      isFirstWall: isFirstWall,
    );
  }

  Wall convertToMM(Wall wall) {
    switch (einheitSelector.selected) {
      case Einheit.cm:
        wall = Wall.fromStart(angle: wall.angle, length: wall.length * 10, start: Corner.fromPoint(point: Offset.zero));
        break;
      case Einheit.m:
        wall = Wall.fromStart(angle: wall.angle, length: wall.length * 1000, start: Corner.fromPoint(point: Offset.zero));
        break;
      default:
        break;
    }
    return wall;
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
                    decoration: const InputDecoration(hintText: "Länge der Wand"),
                  ),
                  const SizedBox(height: 10),
                  einheitSelector,
                  const SizedBox(
                    height: 40,
                    width: 150,
                    child: Stack(alignment: Alignment.bottomLeft, children: [
                      Text(
                        'Winkel: ',
                        style: TextStyle(color: Color.fromARGB(255, 90, 90, 90), decoration: TextDecoration.underline),
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
                    Wall wall = convertToMM(Wall.fromStart(angle: angle, length: length, start: Corner.fromPoint(point: Offset.zero)));
                    addWallEvent.broadcast(wall);
                    Navigator.pop(context);
                  } catch (e) {
                    //TODO: Fehler bei der Eingabe
                  }
                },
              ),
            ],
          );
        });
  }
}
