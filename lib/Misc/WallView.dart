import 'package:aufmass_app/drawing_page/drawing_zone.dart';
import 'package:aufmass_app/drawing_page/paint/paintcontroller.dart';

class WallView { //all of this could be in Wall.dart
  String name;
  late DrawingZone drawingZone;
  final PaintController paintController;
  double height=2;

  WallView({
    required this.name,
    required this.paintController,
  }) {
    paintController.roomName = name;
    drawingZone = DrawingZone(paintController: paintController);
  }
}
