import 'package:aufmass_app/PlanPage/Einheiten/einheitselector.dart';
import 'package:aufmass_app/PlanPage/Misc/input_utils.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff_controller.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/corner.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';

class WerkstoffInputPopup {
  InputState _state = InputState.selectWerkstoff;
  InputState _nextState = InputState.selectWerkstoff;
  Corner? startingPoint;
  Werkstoff? selectedWerkstoff = Werkstoff(name: "", color: Colors.black, typ: WerkstoffTyp.stk);

  int amountOfDrawedPoints = 1;

  final TextEditingController _negX = TextEditingController();
  final TextEditingController _posX = TextEditingController();
  final TextEditingController _negY = TextEditingController();
  final TextEditingController _posY = TextEditingController();

  final inputStateChangedEvent = Event<InputStateEventArgs>();
  Widget _content = const Scaffold();

  InputState get state {
    return _state;
  }

  EinheitSelector einheitSelector = EinheitSelector(
    setGlobal: false,
  );

  void _changeState(InputState newState) {
    _state = newState;
    inputStateChangedEvent.broadcast(InputStateEventArgs(value: _state));
  }

  void _init() {
    switch (_state) {
      case InputState.selectWerkstoff:
        final List<DropdownMenuEntry<Werkstoff>> dropdownList = [];

        for (Werkstoff werkstoff in WerkstoffController().werkstoffe) {
          if (werkstoff.typ != WerkstoffTyp.stk) {
            dropdownList.add(DropdownMenuEntry<Werkstoff>(value: werkstoff, label: werkstoff.name));
          }
        }
        selectedWerkstoff = dropdownList.first.value;

        _content = SingleChildScrollView(
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
        );
        _nextState = InputState.selectStartingpoint;
        break;
      case InputState.selectStartingpoint:
        if (startingPoint == null) {
          _content = const Text("Bitte wählen Sie einen Ausgangspunkt!");
        } else {
          _content = SingleChildScrollView(
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
                        controller: _negY,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "Abstand", prefixIcon: Icon(Icons.arrow_circle_up)),
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
                        controller: _negX,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "Abstand", prefixIcon: Icon(Icons.arrow_circle_left_outlined)),
                      ),
                    ),
                    const SizedBox(
                      width: 125,
                      height: 50,
                    ),
                    SizedBox(
                      width: 125,
                      child: TextField(
                        controller: _posX,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "Abstand", suffixIcon: Icon(Icons.arrow_circle_right_outlined)),
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
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "Abstand", prefixIcon: Icon(Icons.arrow_circle_down)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
          _nextState = InputState.draw;
        }
        break;
      default:
        break;
    }
  }

  Corner? calcStartingpointWithOffset() {
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
      Offset startingpointWithOffset = Offset(x, y) + startingPoint!.point;
      startingPoint = Corner.fromPoint(point: startingpointWithOffset);
      return startingPoint!;
    } catch (e) {
      _changeState(InputState.selectStartingpoint);
      return null;
    }
  }

  bool werkStoffneedsmorePoints() {
    switch (selectedWerkstoff!.typ) {
      case WerkstoffTyp.flaeche:
        break;
      case WerkstoffTyp.linie:
        if (amountOfDrawedPoints == 2) {
          return false;
        }
        break;
      case WerkstoffTyp.point:
        if (amountOfDrawedPoints == 1) {
          return false;
        }
        break;
      default:
        return false;
    }
    return true;
  }

  void finish() {
    _changeState(InputState.selectWerkstoff);
    startingPoint = null;
    selectedWerkstoff = null;
    amountOfDrawedPoints = 1;
    _negX.text = "";
    _posX.text = "";
    _negY.text = "";
    _posY.text = "";
  }

  Future<void> display(BuildContext context) async {
    _init();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Werkstoff einzeichnen'),
          content: _content,
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
                Navigator.pop(context);
                _changeState(_nextState);
              },
            ),
          ],
        );
      },
    );
  }
}
