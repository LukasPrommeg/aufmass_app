import 'package:flutter/material.dart';

enum WerkstoffTyp {
  flaeche,
  linie,
  point,
  stk,
}

//TODO: DB Speichern
class Werkstoff {
  final String name;
  final Color color;
  final WerkstoffTyp typ;

  Werkstoff({required this.name, required this.color, required this.typ});

  bool needsmorePoints(double amountOfDrawedPoints) {
    switch (typ) {
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
}
