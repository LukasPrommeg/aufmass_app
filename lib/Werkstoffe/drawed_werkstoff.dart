import 'package:aufmass_app/PlanPage/2D_Objects/clickable.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/corner.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/flaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/wall.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitcontroller.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';

class DrawedWerkstoff extends EventArgs {
  final ClickAble clickAble;
  late Werkstoff _werkstoff;
  double amount = 0;
  bool hasBeschriftung;
  bool hasLaengen;
  double drawSize;
  double textSize;
  double laengenSize;

  String get amountStr {
    if (clickAble is Flaeche) {
      return "${EinheitController().convertToSelectedSquared(amount).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}²";
    } else if (clickAble is Wall) {
      return "${EinheitController().convertToSelected(amount).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}";
    } else {
      return "-";
    }
  }

  set werkstoff(Werkstoff werkstoff) {
    switch (clickAble.runtimeType) {
      case Flaeche:
        if (werkstoff.typ == WerkstoffTyp.flaeche) {
          _werkstoff = werkstoff;
        } else {
          //TODO: ERROR
        }
        break;
      case Wall:
        if (werkstoff.typ == WerkstoffTyp.linie) {
          _werkstoff = werkstoff;
        } else {
          //TODO: ERROR
        }
        break;
      case Corner:
        if (werkstoff.typ == WerkstoffTyp.point) {
          _werkstoff = werkstoff;
        } else {
          //TODO: ERROR
        }
        break;
      default:
        if (werkstoff.typ == WerkstoffTyp.stk) {
          _werkstoff = werkstoff;
        } else {
          //TODO: ERROR
        }
        break;
    }
  }

  Werkstoff get werkstoff {
    return _werkstoff;
  }

  DrawedWerkstoff({
    required this.clickAble,
    required werkstoff,
    this.hasBeschriftung = true,
    this.hasLaengen = false,
    this.drawSize = 5,
    this.textSize = 15,
    this.laengenSize = 15,
  }) {
    _werkstoff = werkstoff;
    switch (_werkstoff.typ) {
      case WerkstoffTyp.flaeche:
        amount = (clickAble as Flaeche).area;
        break;
      case WerkstoffTyp.linie:
        amount = (clickAble as Wall).length;
        break;
      default:
        break;
    }
  }

  void paint(Canvas canvas) {
    clickAble.paint(canvas, werkstoff.color, drawSize);
    if (hasBeschriftung) {
      double tempAmount = 0;
      if (clickAble is Flaeche) {
        tempAmount = (clickAble as Flaeche).area;
        (clickAble as Flaeche).area = amount;
      } else if (clickAble is Wall) {
        tempAmount = (clickAble as Wall).length;
        (clickAble as Wall).length = amount;
      }
      clickAble.paintBeschriftung(
          canvas, werkstoff.color, werkstoff.name, textSize);
      if (clickAble is Flaeche) {
        (clickAble as Flaeche).area = tempAmount;
      } else if (clickAble is Wall) {
        (clickAble as Wall).length = tempAmount;
      }
    }
    if (hasLaengen) {
      clickAble.paintLaengen(canvas, werkstoff.color, laengenSize);
    }
  }

  bool contains(Offset position) {
    return clickAble.contains(position);
  }
}
