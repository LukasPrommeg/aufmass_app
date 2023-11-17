import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/paint/CircleSlider/circleslider.dart';
//import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class AddPopUpController {
  final TextEditingController _textFieldController = TextEditingController();

  double sliderRange = 300;
  final progressBarColors = [
    const Color.fromARGB(255, 89, 0, 121),
    const Color.fromARGB(255, 255, 0, 187),
    const Color.fromARGB(255, 89, 0, 121),
  ];
  /* final customWidths = CustomSliderWidths(
    trackWidth: 2,
    progressBarWidth: 0,
    handlerSize: 7.5,
    shadowWidth: 0,
  );
  final infoProperties = InfoProperties(
    bottomLabelText: "Grad",
    topLabelText: "Winkel",
  );
  late SleekCircularSlider slider;*/

  AddPopUpController() {
    init();
  }

  void init() {
    /*slider = SleekCircularSlider(
      min: 0,
      max: sliderRange,
      initialValue: 0,
      appearance: CircularSliderAppearance(
        infoProperties: infoProperties,
        customWidths: customWidths,
        customColors: CustomSliderColors(
          progressBarColors: progressBarColors,
          gradientStartAngle: 90 + ((360 - sliderRange) / 2),
          gradientEndAngle: 90 + ((360 - sliderRange) / 2) + sliderRange,
          //gradientEndAngle: 360,
        ),
        angleRange: 360,
        startAngle: 270,
      ),
      onChange: (value) {},
      onChangeStart: (value) {},
      onChangeEnd: (value) {},
      innerWidget: (double value) {
        final TextEditingController controller = TextEditingController();

        controller.text = value.toStringAsFixed(0);
        return Center(
          child: SizedBox(
            width: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (text) {
                    //value = double.parse(text);
                  },
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(hintText: "Winkel"),
                ),
                const Text(
                  "Winkel",
                  style: TextStyle(),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );*/
  }
/*
  SleekCircularSlider setupSlider(double lastWallAngle) {
    SleekCircularSlider newSlider = SleekCircularSlider(
      min: 0,
      max: sliderRange,
      initialValue: sliderRange / 2,
      appearance: CircularSliderAppearance(
        infoProperties: infoProperties,
        customWidths: customWidths,
        customColors: CustomSliderColors(
          progressBarColors: progressBarColors,
          gradientStartAngle: 90 + ((360 - sliderRange) / 2),
          gradientEndAngle: 90 + ((360 - sliderRange) / 2) + sliderRange,
          //gradientEndAngle: 360,
        ),
        angleRange: sliderRange,
        startAngle: 90 + ((360 - sliderRange) / 2) + lastWallAngle,
      ),
      onChange: (value) {},
      onChangeStart: (value) {},
      onChangeEnd: (value) {},
      innerWidget: (double value) {
        final TextEditingController controller = TextEditingController();
        value -= sliderRange / 2;

        if (value < 0) {
          value *= -1;
        }

        controller.text = value.toStringAsFixed(0);
        return Center(
          child: SizedBox(
            width: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (text) {
                    //value = double.parse(text);
                  },
                  controller: controller,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(hintText: "Winkel"),
                ),
                const Text(
                  "Winkel",
                  style: TextStyle(),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );

    return newSlider;
  }*/

  Future<void> displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Wand hinzufügen'),
            content: SizedBox(
              height: 250,
              child: Column(
                children: [
                  TextField(
                    //onChanged: (value) {},
                    controller: _textFieldController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(hintText: "Länge der Wand"),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const CircleSlider(),
                  //slider,
                ],
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('CANCEL'),
                onPressed: () {
                  //setState(() {
                  Navigator.pop(context);
                  //});
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () {
                  //setState(() {
                  //codeDialog = valueText;
                  Navigator.pop(context);
                  //});
                },
              ),
            ],
          );
        });
  }
}
