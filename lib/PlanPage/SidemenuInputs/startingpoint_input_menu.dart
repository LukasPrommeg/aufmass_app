import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitselector.dart';
import 'package:aufmass_app/PlanPage/Misc/alertinfo.dart';
import 'package:flutter/material.dart';

typedef CancelCallback = void Function();
typedef SetStartingpointCallback = void Function(Punkt punkt);
typedef SubmitCallback = void Function(Punkt punkt);

class StartingpointInputMenu extends StatelessWidget {
  final CancelCallback cancelCallback;
  final SetStartingpointCallback setStartingpointCallback;
  final SubmitCallback submitCallback;

  final EinheitSelector einheitSelector = EinheitSelector(
    setGlobal: true,
  );

  final TextEditingController _negX = TextEditingController();
  final TextEditingController _posX = TextEditingController();
  final TextEditingController _negY = TextEditingController();
  final TextEditingController _posY = TextEditingController();

  final Punkt? selectedPunkt;

  StartingpointInputMenu({
    super.key,
    this.selectedPunkt,
    required this.cancelCallback,
    required this.setStartingpointCallback,
    required this.submitCallback,
  });

  Punkt? calcStartingpoint() {
    try {
      double x = 0;
      double y = 0;
      if (_posX.text.isNotEmpty) {
        x = double.parse(_posX.text);
      }
      if (_negX.text.isNotEmpty) {
        x -= double.parse(_negX.text);
      }
      if (_posY.text.isNotEmpty) {
        y = double.parse(_posY.text);
      }
      if (_negY.text.isNotEmpty) {
        y -= double.parse(_negY.text);
      }
      x = einheitSelector.convertToMM(x);
      y = einheitSelector.convertToMM(y);
      Offset startingpointWithOffset = Offset(x, y) + selectedPunkt!.point;
      return Punkt.fromPoint(point: startingpointWithOffset);
    } catch (e) {
      AlertInfo().newAlert("Input wasn't a number!");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool inputEnabled = true;
    if (selectedPunkt == null) {
      inputEnabled = false;
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Abstand vom Ausgangspunkt wählen:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(
            height: 10,
          ),
          einheitSelector,
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 125,
                child: TextField(
                  enabled: inputEnabled,
                  controller: _negY,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "Abstand", prefixIcon: Icon(Icons.arrow_circle_up)),
                  onChanged: (value) {
                    Punkt? calc = calcStartingpoint();
                    if (calc != null) {
                      _negY.text = value;
                      setStartingpointCallback(calc);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 125,
                child: TextField(
                  controller: _negX,
                  enabled: inputEnabled,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "Abstand", prefixIcon: Icon(Icons.arrow_circle_left_outlined)),
                  onChanged: (value) {
                    Punkt? calc = calcStartingpoint();
                    if (calc != null) {
                      setStartingpointCallback(calc);
                    }
                  },
                ),
              ),
              SizedBox(
                width: 125,
                child: TextField(
                  controller: _posX,
                  enabled: inputEnabled,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "Abstand", suffixIcon: Icon(Icons.arrow_circle_right_outlined)),
                  onChanged: (value) {
                    Punkt? calc = calcStartingpoint();
                    if (calc != null) {
                      setStartingpointCallback(calc);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 125,
                child: TextField(
                  controller: _posY,
                  enabled: inputEnabled,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "Abstand", prefixIcon: Icon(Icons.arrow_circle_down)),
                  onChanged: (value) {
                    Punkt? calc = calcStartingpoint();
                    if (calc != null) {
                      setStartingpointCallback(calc);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: inputEnabled
                    ? () {
                        Punkt? calc = calcStartingpoint();
                        if (calc != null) {
                          submitCallback(calc);
                        }
                      }
                    : null,
                child: Container(
                  width: 80,
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(Icons.check),
                      Text("Bestätigen"),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
