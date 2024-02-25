import 'package:aufmass_app/PlanPage/2D_Objects/linie.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:aufmass_app/PlanPage/SidemenuInputs/startingpoint_input_menu.dart';
import 'package:aufmass_app/PlanPage/SidemenuInputs/wall_input_menu.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';

enum CurrentlyHandling {
  nothing,
  lines,
  startingPoint,
}

typedef UndoCallback = void Function();
typedef CancelCallback = void Function();
typedef FinishCallback = bool Function();
typedef AddLinieCallback = void Function(Linie wall);
typedef SetStartingpointCallback = void Function(Punkt punkt);
typedef SubmitCallback = bool Function(Punkt punkt);

class InputHandler {
  CurrentlyHandling _currentlyHandling = CurrentlyHandling.lines;
  CurrentlyHandling get currentlyHandling {
    return _currentlyHandling;
  }

  set currentlyHandling(CurrentlyHandling value) {
    _currentlyHandling = value;
    needsRepaintEvent.broadcast();
  }

  final needsRepaintEvent = Event();

  final UndoCallback undoCallback;
  final CancelCallback cancelCallback;
  final FinishCallback finishCallback;
  final AddLinieCallback addLinieCallback;
  final SetStartingpointCallback setStartingpointCallback;
  final SubmitCallback submitStartingpointCallback;
  final PresetCallback presetCallback;

  bool _drawingGrundflache = true;
  double _lastWallAngle = 0;
  bool _isFirstWall = true;
  double _sliderRange = 300;

  void updateLinienInput({
    bool drawingGrundflache = false,
    double lastWallAngle = 0,
    bool isFirstWall = false,
    double sliderRange = 300,
  }) {
    _drawingGrundflache = drawingGrundflache;
    _lastWallAngle = lastWallAngle;
    _isFirstWall = isFirstWall;
    _sliderRange = sliderRange;

    needsRepaintEvent.broadcast();
  }

  Punkt? _selectedPunkt;
  Punkt get selectedPunkt {
    if (_selectedPunkt != null) {
      return _selectedPunkt!;
    }
    throw Exception("Selected Point was null!");
  }

  Punkt? startingPoint;

  void updateStartingpointInput({Punkt? selectedPunkt}) {
    _selectedPunkt = selectedPunkt;
    needsRepaintEvent.broadcast();
  }

  InputHandler({
    required this.undoCallback,
    required this.cancelCallback,
    required this.finishCallback,
    required this.addLinieCallback,
    required this.setStartingpointCallback,
    required this.submitStartingpointCallback,
    required this.presetCallback,
  });

  Widget display() {
    switch (_currentlyHandling) {
      case CurrentlyHandling.nothing:
        return const Text("HOW DID WE END UP HERE?");
      case CurrentlyHandling.lines:
        return WallInputMenu(
          drawingGrundflache: _drawingGrundflache,
          isFirstWall: _isFirstWall,
          lastWallAngle: _lastWallAngle,
          sliderRange: _sliderRange,
          key: UniqueKey(),
          undoCallback: undoCallback,
          cancelCallback: () {
            cancelCallback();
            if (_drawingGrundflache) {
              _currentlyHandling = CurrentlyHandling.lines;
            }
          },
          finishCallback: () {
            if (finishCallback()) {
              _currentlyHandling = CurrentlyHandling.nothing;
            }
            needsRepaintEvent.broadcast();
          },
          addWallCallback: (wall) {
            addLinieCallback(wall);
            needsRepaintEvent.broadcast();
          },
          presetCallback: (presetName) => presetCallback(presetName),
        );
      case CurrentlyHandling.startingPoint:
        return StartingpointInputMenu(
          selectedPunkt: _selectedPunkt,
          cancelCallback: () {
            _currentlyHandling = CurrentlyHandling.nothing;
            cancelCallback();
          },
          setStartingpointCallback: (punkt) {
            setStartingpointCallback(punkt);
          },
          submitCallback: (punkt) {
            submitStartingpointCallback(punkt);
            startingPoint = punkt;
            needsRepaintEvent.broadcast();
          },
        );
    }
  }
}
