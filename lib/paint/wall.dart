import 'package:event/event.dart';

class Wall extends EventArgs {
  Wall({required this.angle, required this.length});

  final double angle;
  final double length;
  bool selected = false;
}
