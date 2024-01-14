import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:flutter/material.dart';

class WerkstoffController {
  static final WerkstoffController _instance = WerkstoffController._internal();

  factory WerkstoffController() {
    return _instance;
  }

  WerkstoffController._internal() {
    //Constructor
    werkstoffe.add(Werkstoff(name: "Fliese", color: Colors.purple, typ: WerkstoffTyp.flaeche));
    werkstoffe.add(Werkstoff(name: "Dichtband", color: Colors.blue, typ: WerkstoffTyp.linie));
    werkstoffe.add(Werkstoff(name: "Manschette", color: Colors.brown, typ: WerkstoffTyp.point));
    werkstoffe.add(Werkstoff(name: "187", color: Colors.brown, typ: WerkstoffTyp.stk));
  }

  final List<Werkstoff> werkstoffe = [];
}
