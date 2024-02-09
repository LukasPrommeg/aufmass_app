import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/grundflaeche.dart';
import 'package:flutter/material.dart';

class PolyPainter extends CustomPainter {
  PolyPainter({required Listenable repaint}) : super(repaint: repaint);
  Grundflaeche? _grundFlaeche;
  DrawedWerkstoff? clickedWerkstoff;
  bool selectCorner = false;
  List<Punkt> hiddenCorners = [];
  Punkt? selectedCorner;

  void reset() {
    _grundFlaeche = null;
    clickedWerkstoff = null;
    selectCorner = false;
    hiddenCorners.clear();
    selectedCorner = null;
  }

  void drawGrundflaeche(Grundflaeche? grundFlaeche) {
    _grundFlaeche = grundFlaeche;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_grundFlaeche != null) {
      _grundFlaeche!.paintGrundflaeche(canvas);

      if (selectCorner) {
        selectedCorner?.selected = true;
        _grundFlaeche!.paintCornerHB(canvas, hiddenCorners, Colors.purple);
        selectedCorner?.selected = false;
      }
      //TODO: TEMP
      _grundFlaeche!.paintOverlaps(canvas);
    }
  }

  @override
  bool shouldRepaint(PolyPainter oldDelegate) {
    return true;
  }
}
