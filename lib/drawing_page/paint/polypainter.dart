import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/drawing_page/paint/corner.dart';
import 'package:aufmass_app/drawing_page/paint/grundflaeche.dart';
import 'package:flutter/material.dart';

class PolyPainter extends CustomPainter {
  PolyPainter({required Listenable repaint}) : super(repaint: repaint);
  List<DrawedWerkstoff> _werkstoffe = [];
  Grundflaeche? _grundFlaeche;
  DrawedWerkstoff? clickedWerkstoff;
  bool selectStartingpoint = false;
  Corner? selectedStartingpoint;

  void drawGrundflaeche(Grundflaeche? grundFlaeche) {
    _grundFlaeche = grundFlaeche;
  }

  void drawWerkstoffe(List<DrawedWerkstoff> werkstoffe) {
    _werkstoffe = werkstoffe;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_grundFlaeche != null) {
      _grundFlaeche!.paintGrundflaeche(canvas);
      if (selectStartingpoint) {
        selectedStartingpoint?.selected = true;
        _grundFlaeche!.paintCornerHB(canvas);
        selectedStartingpoint?.selected = false;
      }
    }
    for (DrawedWerkstoff werkstoff in _werkstoffe) {
      werkstoff.paint(canvas);
    }
  }

  @override
  bool shouldRepaint(PolyPainter oldDelegate) {
    return true;
  }
}
