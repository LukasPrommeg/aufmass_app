import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test_diplom/paint/CircleSlider/sliderpainter.dart';

class CircleSlider extends StatelessWidget {
  final double radius;
  final double centerAngle;
  final double maxAngle;

  const CircleSlider(
      {super.key,
      this.radius = 100,
      this.centerAngle = 0,
      this.maxAngle = 150});

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    textEditingController.value = TextEditingValue(text: "0");

    return GestureDetector(
      child: SizedBox(
        height: radius + (radius / 10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: SizedBox(
                width: radius / 2,
                height: radius,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 12.5,
                    ),
                    TextField(
                      //onChanged: (value) {},
                      controller: textEditingController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      decoration: const InputDecoration(
                        counter: Center(),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomPaint(
              painter: SliderPainter(
                  radius: radius, centerAngle: 0, maxAngle: maxAngle),
            ),
          ],
        ),
      ),
    );
  }
}
