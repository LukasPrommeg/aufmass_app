import 'package:event/event.dart';
import 'package:flutter_test_diplom/paint/corner.dart';

class Wall extends EventArgs {
  Wall({required this.angle, required this.length});

  final double angle;
  final double length;
  bool selected = false;
  Wall? next;
  Corner? start;
  Corner? end;
}
