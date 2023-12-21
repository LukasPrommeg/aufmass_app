import 'package:flutter/material.dart';
import 'package:aufmass_app/Misc/clickable.dart';

class Corner extends ClickAble {
  final Offset center;

  Corner({required this.center, double hitboxSize = 20}) : super(hbSize: hitboxSize);

  @override
  @protected
  void calcHitbox() {
    if (offset.isInfinite) {
      hitbox = Path();
      Radius radius = Radius.circular(hbSize);

      hitbox.moveTo(0, 0 - hbSize);
      hitbox.arcToPoint(Offset(hbSize, 0), radius: radius);
      hitbox.arcToPoint(Offset(0, hbSize), radius: radius);
      hitbox.arcToPoint(Offset(-hbSize, 0), radius: radius);
      hitbox.arcToPoint(Offset(0, -hbSize), radius: radius);

      moveTo(center);
    }
  }
}
