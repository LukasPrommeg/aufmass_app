import 'package:flutter_test_diplom/drawing_page/drawing_zone.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class Room {
  String name;
  late DrawingZone drawingZone;
  final PaintController paintController;

  Room({
    required this.name,
    required this.paintController,
  }) {
    drawingZone = DrawingZone(paintController: paintController);
  }
}
