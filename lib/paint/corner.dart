import 'package:flutter/material.dart';

class Corner {
  Corner({required this.path, required this.center});

  final Path path;
  final Offset center;
  bool selected = false;
}
