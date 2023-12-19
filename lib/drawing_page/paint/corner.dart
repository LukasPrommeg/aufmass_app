import 'package:flutter/material.dart';
import 'package:aufmass_app/Misc/hitbox.dart';

class Corner extends ClickAble {
  final Offset center;

  Corner({required this.center, double hitboxSize = 10}) : super(size: hitboxSize);

  @override
  @protected
  void calcHitbox() {
    if (offset.isInfinite) {
      hitbox = Path();
      Radius radius = Radius.circular(size);

      hitbox.moveTo(0, 0 - size);
      hitbox.arcToPoint(const Offset(10, 0), radius: radius);
      hitbox.arcToPoint(const Offset(0, 10), radius: radius);
      hitbox.arcToPoint(const Offset(-10, 0), radius: radius);
      hitbox.arcToPoint(const Offset(0, -10), radius: radius);

      moveTo(center);
    }
  }
}
