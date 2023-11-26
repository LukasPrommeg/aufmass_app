import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/CircleSlider/circleslider.dart';
import 'package:event/event.dart';
import 'package:flutter_test_diplom/drawing_page/paint/wall.dart';

class AddPopUpController {
  final TextEditingController _textFieldController = TextEditingController();

  final double sliderRange;
  double lastWallAngle = 0;
  bool isFirstWall = true;
  final addWallEvent = Event<Wall>();

  AddPopUpController({
    this.sliderRange = 300,
  }) {
    init(0, false);
  }

  void init(double lastWallAngle, bool isFirstWall) {
    this.lastWallAngle = lastWallAngle;
    this.isFirstWall = isFirstWall;
  }

  Future<void> displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Wand hinzufügen'),
            content: SizedBox(
              height: 280,
              child: Column(
                children: [
                  TextField(
                    controller: _textFieldController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(hintText: "Länge der Wand"),
                  ),
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
                  CircleSlider(
                    radius: 75,
                    centerAngle: 0,
                    maxAngle: sliderRange / 2,
                    hitboxSize: 0.1,
                    isFirstWall: isFirstWall,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              MaterialButton(
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
                  addWallEvent.broadcast();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
