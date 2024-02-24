import 'package:aufmass_app/PlanPage/2D_Objects/linie.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:aufmass_app/PlanPage/CircleSlider/circleslider.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitselector.dart';
import 'package:aufmass_app/PlanPage/Misc/lengthinput.dart';
import 'package:flutter/material.dart';

typedef UndoCallback = void Function();
typedef CancelCallback = void Function();
typedef FinishCallback = void Function();
typedef AddWallCallback = void Function(Linie wall);

class WallInputMenu extends StatelessWidget {
  final UndoCallback undoCallback;
  final CancelCallback cancelCallback;
  final FinishCallback finishCallback;
  final AddWallCallback addWallCallback;

  final bool drawingGrundflache;
  final double lastWallAngle;
  final bool isFirstWall;
  final double sliderRange;

  const WallInputMenu({
    super.key,
    required this.undoCallback,
    required this.cancelCallback,
    required this.finishCallback,
    required this.addWallCallback,
    this.drawingGrundflache = false,
    this.lastWallAngle = 0,
    this.isFirstWall = false,
    this.sliderRange = 300,
  });

  @override
  Widget build(BuildContext context) {
    LengthInput wallInput = LengthInput(
      drawingGrundflaeche: drawingGrundflache,
      hintText: "Länge der Wand",
    );
    EinheitSelector einheitSelector = EinheitSelector(
      setGlobal: true,
    );
    CircleSlider slider = CircleSlider(
      radius: 75,
      centerAngle: lastWallAngle,
      maxAngle: sliderRange / 2,
      hitboxSize: 0.1,
      isFirstWall: isFirstWall,
    );

    return SingleChildScrollView(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: undoCallback,
                child: Container(
                    width: 80,
                    height: 50,
                    alignment: Alignment.bottomCenter,
                    child: const Column(
                      children: [
                        Icon(Icons.undo),
                        Text("Rückgängig"),
                      ],
                    )),
              ),
              ElevatedButton(
                onPressed: () {
                  double length = wallInput.value;
                  if (length == 0 && !wallInput.useMaxValue) {
                    return;
                  }

                  length = einheitSelector.convertToMM(length);

                  double angle = slider.centerAngle;
                  angle += -slider.value;
                  Linie wall = Linie.fromStart(angle: angle, length: length, start: Punkt.fromPoint(point: Offset.zero));

                  addWallCallback(wall);
                },
                child: Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        Icon(Icons.draw),
                        Text("Zeichnen"),
                      ],
                    )),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: cancelCallback,
                child: Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        Icon(Icons.cancel),
                        Text("Abbrechen"),
                      ],
                    )),
              ),
              ElevatedButton(
                onPressed: finishCallback,
                child: Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        Icon(Icons.hexagon_outlined),
                        Text("Fertigstellen"),
                      ],
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
