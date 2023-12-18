import 'package:flutter_test_diplom/drawing_page/drawing_zone.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class Room {
  String name;
  final DrawingZone drawingZone;
  final PaintController paintController;

  Room({
    required this.name,
    required this.drawingZone,
    required this.paintController,
  });
}
