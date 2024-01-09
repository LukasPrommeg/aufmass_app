import 'package:aufmass_app/Einheiten/einheitselector.dart';
import 'package:aufmass_app/PopUP/previewpainter.dart';
import 'package:aufmass_app/drawing_page/paint/corner.dart';
import 'package:aufmass_app/drawing_page/paint/wall.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';

enum InputState {
  selectStartingpoint,
  draw,
}

class InputStateEventArgs extends EventArgs {
  final InputState value;

  InputStateEventArgs({required this.value});
}

class AusnahmeInput {
  InputState _state = InputState.selectStartingpoint;
  InputState _nextState = InputState.selectStartingpoint;
  Widget _content = Scaffold();
  final inputStateChangedEvent = Event<InputStateEventArgs>();

  Wall? infront;
  Corner? startingPoint;
  Wall? behind;

  final TextEditingController _negX = TextEditingController();
  final TextEditingController _posX = TextEditingController();
  final TextEditingController _negY = TextEditingController();
  final TextEditingController _posY = TextEditingController();
  final EinheitSelector einheitSelector = EinheitSelector(setGlobal: false);

  InputState get state {
    return _state;
  }

  AusnahmeInput();

  void _changeState(InputState newState) {
    _state = newState;
    inputStateChangedEvent.broadcast(InputStateEventArgs(value: _state));
  }

  void _init() {
    switch (_state) {
      case InputState.selectStartingpoint:
        if (startingPoint == null) {
          _content = const Text("Bitte wählen Sie einen Ausgangspunkt!");
        } else {
          _content = SizedBox(
            height: 250,
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
    }
  }

  void finish() {
    _changeState(InputState.selectStartingpoint);
    infront = null;
    startingPoint = null;
    behind = null;
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
