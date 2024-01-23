import 'package:aufmass_app/2D_Objects/flaeche.dart';

class Einkerbung extends Flaeche {
  double tiefe;

  Einkerbung({
    required this.tiefe,
    required super.walls,
  });
}
