import 'dart:ui';
import 'package:aufmass_app/2D_Objects/flaeche.dart';
import 'package:aufmass_app/2D_Objects/wall.dart';
import 'package:aufmass_app/Misc/overlap.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:flutter/material.dart';

class Einkerbung extends Flaeche {
  String name;
  double tiefe;
  List<Overlap> overlaps = [];

  double scale = 0;
  Offset center = Offset.zero;

  Einkerbung({
    required this.name,
    required this.tiefe,
    required List<Wall> walls,
  }) : super(walls: walls);

  void paintIntersects(Canvas canvas) {
    for (Overlap overlap in overlaps) {
      overlap = Overlap(einkerbung: overlap.einkerbung, overlapObj: overlap.overlapObj, werkstoff: overlap.werkstoff);
      overlap.editMode = true;
      overlap.initScale(scale, center);
      overlap.paint(canvas);
    }
  }

  @override
  void initScale(double scale, Offset center) {
    for (Overlap overlap in overlaps) {
      overlap.initScale(scale, center);
    }
    super.initScale(scale, center);
    this.scale = scale;
    this.center = center;
  }

  void findOverlap(List<DrawedWerkstoff> werkstoffe) {
    for (DrawedWerkstoff werkstoff in werkstoffe) {
      Overlap overlap = Overlap(einkerbung: this, overlapObj: werkstoff.clickAble, werkstoff: werkstoff.werkstoff);
      if (overlap.isOverlapping) {
        overlaps.add(overlap);
      }
    }
  }
}
