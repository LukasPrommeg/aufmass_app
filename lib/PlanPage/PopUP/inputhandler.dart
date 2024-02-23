enum CurrentlyHandling {
  nothing,
  grundflaeche,
  einkerbung,
  werkstoff,
}

class InputHandler {
  CurrentlyHandling currentlyHandling = CurrentlyHandling.nothing;
  bool active = false;
}
