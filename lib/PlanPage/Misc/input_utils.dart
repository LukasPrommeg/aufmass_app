import 'package:event/event.dart';

enum InputState {
  selectWerkstoff,
  inputEinkerbung,
  selectStartingpoint,
  draw,
}

class InputStateEventArgs extends EventArgs {
  final InputState value;

  InputStateEventArgs({required this.value});
}
