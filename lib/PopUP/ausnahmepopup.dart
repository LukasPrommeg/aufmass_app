import 'package:aufmass_app/Einheiten/einheitselector.dart';
import 'package:aufmass_app/Misc/input_utils.dart';
import 'package:aufmass_app/PopUP/previewpainter.dart';
import 'package:aufmass_app/Misc/lengthinput.dart';
import 'package:aufmass_app/2D_Objects/corner.dart';
import 'package:aufmass_app/2D_Objects/wall.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';

class AusnahmePopup {
  InputState _state = InputState.inputEinkerbung;
  InputState _nextState = InputState.inputEinkerbung;
  Widget _content = const Scaffold();
  final inputStateChangedEvent = Event<InputStateEventArgs>();

  Wall? infront;
  Corner? startingPoint;
  Wall? behind;
  double tiefe = double.infinity;

  final TextEditingController _negX = TextEditingController();
  final TextEditingController _posX = TextEditingController();
  final TextEditingController _negY = TextEditingController();
  final TextEditingController _posY = TextEditingController();
  final EinheitSelector einheitSelector = EinheitSelector(setGlobal: false);
  final LengthInput _tiefenInput = LengthInput(
    hintText: "Tiefe der Einkerbung",
    maxText: "Keine Tiefe",
    drawingGrundflaeche: false,
    btnText: "Keine",
    useMaxValue: true,
  );

  InputState get state {
    return _state;
  }

  AusnahmePopup();

  void _changeState(InputState newState) {
    _state = newState;
    inputStateChangedEvent.broadcast(InputStateEventArgs(value: _state));
  }

  void _init() {
    switch (_state) {
      case InputState.inputEinkerbung:
        _content = SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Wählen Sie die tiefe der Einkerbung"),
              const SizedBox(
                height: 10,
              ),
              einheitSelector,
              const SizedBox(
                height: 10,
              ),
              _tiefenInput,
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
          if (_tiefenInput.value != 0) {
            tiefe = einheitSelector.convertToMM(_tiefenInput.value);
          }
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
                    SizedBox(
                      width: 125,
                      height: 50,
                      child: CustomPaint(
                        painter: PreviewPainter(const Offset(125, 50), infront: infront!, behind: behind!),
                      ),
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
      case InputState.draw:
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

  void finish() {
    _changeState(InputState.inputEinkerbung);
    infront = null;
    startingPoint = null;
    behind = null;
    _negX.text = "";
    _posX.text = "";
    _negY.text = "";
    _posY.text = "";
    tiefe = double.infinity;
    _tiefenInput.useMaxValue = true;
  }

  Future<void> display(BuildContext context) async {
    _init();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Einkerbung einzeichnen'),
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

  //TODO: zum Testen
  void setState(InputState state) {
    _state = state;
  }
}
