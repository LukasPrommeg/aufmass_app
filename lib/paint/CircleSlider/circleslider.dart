import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/paint/CircleSlider/sliderpainter.dart';

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
        border: OutlineInputBorder(
          gapPadding: 0,
        )
        /*border: OutlineInputBorder(
          //borderSide: BorderSide(color: Colors.red, width: 1.0),
          //gapPadding: 2,
          ),*/
        );

    return GestureDetector(
      key: boxKey,
      behavior: HitTestBehavior.translucent,
      onTapUp: (details) {
        updateValWithPoint(details.localPosition);
      },
      onPanStart: (details) {
        updateValWithPoint(details.localPosition);
      },
      onPanUpdate: (details) {
        updateValWithPoint(details.localPosition);
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
            //alignment: Alignment.center,
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
                            } else {
                              //Change Style
                            }
                          } catch (e) {}
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

  void updateValWithPoint(Offset point) {
    RenderBox painterBox =
        boxKey.currentContext!.findRenderObject() as RenderBox;

    Offset offset = Offset(painterBox.size.width, painterBox.size.height);

    sliderPainter.updateValueWithPoint(point - (offset / 2));
    centerTextFieldController.value =
        TextEditingValue(text: sliderPainter.val.abs().toStringAsFixed(0));
  }
}
