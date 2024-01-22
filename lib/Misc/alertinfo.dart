import 'package:flutter/material.dart';

//ignore: must_be_immutable
class AlertInfo extends StatefulWidget {
  static final AlertInfo _instance = AlertInfo._internal();

  @protected
  final ValueNotifier<int> _newValNotifier = ValueNotifier<int>(0);

  factory AlertInfo() {
    return _instance;
  }

  newAlert(String text, {Color textColor = Colors.red}) {
    _instance.text = text;
    this.textColor = textColor;
    _instance._newValNotifier.value++;
  }

  AlertInfo._internal() {
    //Constructor
  }

  String text = "";
  Color textColor = Colors.red;

  @override
  State<AlertInfo> createState() => _AlertInfoState();
}

class _AlertInfoState extends State<AlertInfo> {
  static bool blocked = false;

  TextStyle _style = const TextStyle(
    fontSize: 20,
    color: Colors.red,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    widget._newValNotifier.addListener(() => _fadeOut());
  }

  Future<void> _fadeOut() async {
    if (blocked) {
      return;
    }
    blocked = true;

    setState(() {
      _style = TextStyle(
        fontSize: 20,
        color: widget.textColor.withOpacity(1),
        fontWeight: FontWeight.bold,
      );
    });

    for (int i = 100; i > 0; i--) {
      setState(() {
        _style = TextStyle(
          fontSize: 20,
          color: widget.textColor.withOpacity(i / 100),
          fontWeight: FontWeight.bold,
        );
      });
      await Future.delayed(const Duration(milliseconds: 10));
    }

    widget.text = "";
    blocked = false;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        widget.text,
        style: _style,
      ),
    );
  }
}
