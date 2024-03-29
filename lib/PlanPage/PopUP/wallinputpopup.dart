import 'package:aufmass_app/PlanPage/Misc/lengthinput.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/CircleSlider/circleslider.dart';
import 'package:event/event.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitcontroller.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitselector.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/linie.dart';

class WallInputPopup {
  final double sliderRange;
  final addWallEvent = Event<Linie>();
  EinheitSelector einheitSelector = EinheitSelector(
    setGlobal: false,
  );
  late CircleSlider slider;

  WallInputPopup({
    this.sliderRange = 300,
  }) {
    init(0, true);
  }

  void init(double lastWallAngle, bool isFirstWall) {
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

  Linie convertToMM(Linie wall) {
    switch (einheitSelector.selected) {
      case Einheit.cm:
        wall = Linie.fromStart(angle: wall.angle, length: wall.length * 10, start: Punkt.fromPoint(point: Offset.zero));
        break;
      case Einheit.m:
        wall = Linie.fromStart(angle: wall.angle, length: wall.length * 1000, start: Punkt.fromPoint(point: Offset.zero));
        break;
      default:
        break;
    }
    return wall;
  }

  Future<void> display(BuildContext context, bool drawingGrundflache) async {
    LengthInput wallInput = LengthInput(
      drawingGrundflaeche: drawingGrundflache,
      hintText: "Länge der Wand",
    );

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wand hinzufügen'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                wallInput,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        slider.value = (slider.value * -1) - 90;
                      },
                      icon: const Icon(Icons.rotate_90_degrees_ccw),
                    ),
                    slider,
                    IconButton(
                      onPressed: () {
                        slider.value = (slider.value * -1) + 90;
                      },
                      icon: const Icon(Icons.rotate_90_degrees_cw),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
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
                double length = wallInput.value;
                if (length == 0 && !wallInput.useMaxValue) {
                  return;
                }
                double angle = slider.centerAngle;
                angle += -slider.value;
                Linie wall = convertToMM(Linie.fromStart(angle: angle, length: length, start: Punkt.fromPoint(point: Offset.zero)));
                addWallEvent.broadcast(wall);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
