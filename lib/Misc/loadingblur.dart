import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//ignore: must_be_immutable
class LoadingBlur extends StatefulWidget {
  static final LoadingBlur _instance = LoadingBlur._internal();

  @protected
  final ValueNotifier<int> _update = ValueNotifier<int>(0);
  bool _blur = false;

  factory LoadingBlur() {
    return _instance;
  }

  LoadingBlur._internal() {
    //Constructor
  }

  enableBlur() {
    _instance._blur = true;
    _instance._update.value++;
  }

  disableBlur() {
    _instance._blur = false;
    _instance._update.value++;
  }

  @override
  State<LoadingBlur> createState() => _LoadingBlurState();
}

class _LoadingBlurState extends State<LoadingBlur> {
  Widget blur = Container();

  @override
  void initState() {
    super.initState();
    widget._update.addListener(() {
      _update();
    });
    _update();
  }

  void _update() {
    setState(() {
      if (widget._blur) {
        blur = Container(
          color: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
            child: Container(
              color: Colors.black.withOpacity(0.25), // Adjust the opacity as needed
              child: Center(
                child: SpinKitWave(
                  color: Colors.purple.withOpacity(0.75),
                  itemCount: 5,
                  size: 50,
                ),
              ),
            ),
          ),
        );
      } else {
        blur = Container();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return blur;
  }
}
