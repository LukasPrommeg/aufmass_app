import 'package:aufmass_app/2D_Objects/flaeche.dart';
import 'package:aufmass_app/2D_Objects/wall.dart';

class Einkerbung extends Flaeche {
  double tiefe;

  Einkerbung({
    required this.tiefe,
    required List<Wall> walls,
  }) : super(walls: walls);
}
