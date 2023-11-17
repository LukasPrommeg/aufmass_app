import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/paint/CircleSlider/sliderpainter.dart';

class CircleSlider extends StatelessWidget {
  final double radius;

  const CircleSlider({super.key, this.radius = 75});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              "187°",
              textAlign: TextAlign.end,
            ),
          ),
          CustomPaint(
            painter: SliderPainter(radius: radius),
          ),
        ],
      ),
    );
  }
}
