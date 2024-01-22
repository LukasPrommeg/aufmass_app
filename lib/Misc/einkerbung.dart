import 'package:aufmass_app/drawing_page/paint/flaeche.dart';

class Einkerbung extends Flaeche {
  double tiefe;

  Einkerbung({
    required this.tiefe,
    required super.walls,
  });
}
