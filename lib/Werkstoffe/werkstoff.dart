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
}
