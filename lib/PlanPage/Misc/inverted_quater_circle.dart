import 'package:flutter/material.dart';

enum Corner {
  leftTop,
  leftBottom,
  rightTop,
  rightBottom,
}

class InvertedCorner extends StatelessWidget {
  final Corner corner;
  final double radius;
  final Color color;

  const InvertedCorner({
    super.key,
    required this.corner,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radius * 2,
      width: radius * 2,
      child: ClipPath(
        clipper: CornerClipper(
          corner: corner,
          radius: radius,
          color: color,
        ),
        child: Container(
          height: 2 * radius,
          width: 2 * radius,
          color: color,
        ),
      ),
    );
  }
}

class CornerClipper extends CustomClipper<Path> {
  final Corner corner;
  final double radius;
  final Color color;

  const CornerClipper({
    required this.corner,
    required this.radius,
    required this.color,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();
    Radius radiusOBJ = Radius.circular(radius);

    switch (corner) {
      case Corner.rightTop:
        path.moveTo(size.width / 2, 0);
        path.arcToPoint(
          Offset(size.width, size.height / 2),
          radius: radiusOBJ,
        );
        path.lineTo(size.width, 0);
        path.close();
        break;
      case Corner.rightBottom:
        path.moveTo(size.width, size.height / 2);
        path.arcToPoint(
          Offset(size.width / 2, size.height),
          radius: radiusOBJ,
        );
        path.lineTo(size.width, size.height);
        path.close();
        break;
      case Corner.leftBottom:
        path.moveTo(size.width / 2, size.height);
        path.arcToPoint(
          Offset(0, size.height / 2),
          radius: radiusOBJ,
        );
        path.lineTo(0, size.height);
        path.close();
        break;
      case Corner.leftTop:
        path.moveTo(0, size.height / 2);
        path.arcToPoint(
          Offset(size.width / 2, 0),
          radius: radiusOBJ,
        );
        path.lineTo(0, 0);
        path.close();
        break;
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
