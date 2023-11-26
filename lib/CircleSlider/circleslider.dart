import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/CircleSlider/sliderpainter.dart';

class CircleSlider extends StatelessWidget {
  final double radius;
  final double hitboxSize;
  final double centerAngle;
  final double maxAngle;
  final bool isFirstWall;
  final _repaint = ValueNotifier<int>(0);

  late SliderPainter sliderPainter;
  final TextEditingController centerTextFieldController =
      TextEditingController(text: "0");

  final painterKey = GlobalKey();
  final boxKey = GlobalKey();

  CircleSlider({
    super.key,
    this.radius = 100,
    this.hitboxSize = 0.2,
    this.centerAngle = 0,
    this.maxAngle = 150,
    this.isFirstWall = false,
  }) {
    sliderPainter = SliderPainter(
      repaint: _repaint,
      radius: radius,
      centerAngle: centerAngle,
      maxAngle: maxAngle,
      isFirstWall: isFirstWall,
    );
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration decoration = const InputDecoration(
      counter: Center(),
    );

    return GestureDetector(
      key: boxKey,
      behavior: HitTestBehavior.translucent,
      onTapUp: (details) {
        _updateValWithPoint(details.localPosition);
      },
      onPanStart: (details) {
        _updateValWithPoint(details.localPosition);
      },
      onPanUpdate: (details) {
        _updateValWithPoint(details.localPosition);
      },
      child: Theme(
        data: ThemeData(
          primaryColor: Colors.redAccent,
          primaryColorDark: Colors.red,
        ),
        child: SizedBox(
          height: 2.5 * radius,
          width: 2.5 * radius,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: radius - (radius * hitboxSize),
                  height: radius - (radius * hitboxSize),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 6.5,
                      ),
                      TextField(
                        onSubmitted: (value) {
                          try {
                            double angle = double.parse(value);
                            if (angle >= 0 && angle <= maxAngle ||
                                angle < 0 && angle >= (maxAngle * -1)) {
                              sliderPainter.updateValueWithAngle(angle);
                              centerTextFieldController.value =
                                  TextEditingValue(
                                      text: sliderPainter.val
                                          .abs()
                                          .toStringAsFixed(0));
                            } else {
                              //TODO: Change Style
                            }
                          } catch (e) {
                            //TODO: Change Style
                          }
                        },
                        controller: centerTextFieldController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        decoration: decoration,
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: CustomPaint(
                  key: painterKey,
                  painter: sliderPainter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateValWithPoint(Offset point) {
    RenderBox painterBox =
        boxKey.currentContext!.findRenderObject() as RenderBox;

    Offset offset = Offset(painterBox.size.width, painterBox.size.height);

    sliderPainter.updateValueWithPoint(point - (offset / 2));
    centerTextFieldController.value =
        TextEditingValue(text: sliderPainter.val.abs().toStringAsFixed(0));
  }
}
