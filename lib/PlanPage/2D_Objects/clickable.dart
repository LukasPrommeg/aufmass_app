import 'package:aufmass_app/PlanPage/2D_Objects/flaeche.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';

abstract class ClickAble extends EventArgs {
  Path hitbox = Path();
  double hbSize = 10;
  bool selected = false;
  Offset posBeschriftung = const Offset(0, 0);
  Rect size = Rect.zero;
  Path unscaledPath = Path();

  Paint _paintStyle = Paint()
    ..color = Colors.red
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;

  ClickAble({required this.hbSize});

  ClickAble.merge(ClickAble a, ClickAble b, [double? size]) {
    if (size != null) {
      hbSize = size;
    }
    //TODO: Maybe merge Hitboxes
  }

  bool contains(Offset position) {
    if (hitbox.contains(position)) {
      return true;
    } else {
      return false;
    }
  }

  void paintHB(Canvas canvas, [Color? overrideBaseColor, Color? overrideSelectedColor]) {
    if (selected) {
      if (overrideSelectedColor == null) {
        _paintStyle = Paint()
          ..color = Colors.green
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;
      } else {
        _paintStyle = Paint()
          ..color = overrideSelectedColor
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;
      }
    } else {
      if (overrideBaseColor == null) {
        _paintStyle = Paint()
          ..color = Colors.red
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;
      } else {
        _paintStyle = Paint()
          ..color = overrideBaseColor
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;
      }
    }

    Paint areaPaint;
    if (this is Flaeche) {
      areaPaint = Paint()
        ..color = _paintStyle.color.withOpacity(0.4)
        ..style = PaintingStyle.fill;
    } else {
      areaPaint = Paint()
        ..color = _paintStyle.color.withOpacity(0.2)
        ..style = PaintingStyle.fill;
    }

    calcHitbox();

    canvas.drawPath(hitbox, areaPaint);
    canvas.drawPath(hitbox, _paintStyle);
  }

  void paint(Canvas canvas, Color color, double size);

  void paintBeschriftung(Canvas canvas, Color color, String text, double size);

  void paintLaengen(Canvas canvas, Color color, double size);

  @protected
  void calcHitbox();

  void initScale(double scale, Offset center) {
    calcHitbox();
  }
}
