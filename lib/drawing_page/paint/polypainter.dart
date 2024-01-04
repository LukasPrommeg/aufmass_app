import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/drawing_page/paint/corner.dart';
import 'package:aufmass_app/drawing_page/paint/grundflaeche.dart';
import 'package:flutter/material.dart';

class PolyPainter extends CustomPainter {
  PolyPainter({required Listenable repaint}) : super(repaint: repaint);
  List<DrawedWerkstoff> _werkstoffe = [];
  Grundflaeche? _grundFlaeche;
  DrawedWerkstoff? clickedWerkstoff;
  bool selectCorner = false;
  List<Corner> hiddenCorners = [];
  Corner? selectedCorner;

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

  void drawWerkstoffe(List<DrawedWerkstoff> werkstoffe) {
    _werkstoffe = werkstoffe;
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
