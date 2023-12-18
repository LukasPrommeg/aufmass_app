import 'package:event/event.dart';

enum Einheit { mm, cm, m }

class EinheitEventArgs extends EventArgs {
  final Einheit selected;

  EinheitEventArgs({required this.selected});
}

class EinheitController {
  static final EinheitController _instance = EinheitController._internal();

  final updateEinheitEvent = Event<EinheitEventArgs>();

  factory EinheitController() {
    return _instance;
  }

  EinheitController._internal() {
    //Constructor
  }

  Set<Einheit> _einheitSelection = <Einheit>{Einheit.mm};

  Einheit get selectedEinheit {
    return _einheitSelection.first;
  }

  set selectedEinheit(Einheit newSel) {
    _einheitSelection = {newSel};
    updateEinheitEvent.broadcast();
  }
}
