import 'package:flutter/material.dart';

class AlertInfo {
  static final AlertInfo _instance = AlertInfo._internal();

  @protected
  final ValueNotifier<int> _newValNotifier = ValueNotifier<int>(0);
  String text = "";
  Color textColor = Colors.red;

  factory AlertInfo() {
    return _instance;
  }

  newAlert(String text, {Color textColor = Colors.red}) {
    _instance.text = text;
    this.textColor = textColor;
    _instance._newValNotifier.value++;
  }

  Widget widget() {
    return AlertInfoWidget(
      newValNotifier: _newValNotifier,
    );
  }

  AlertInfo._internal() {
    //Constructor
  }
}

//ignore: must_be_immutable
class AlertInfoWidget extends StatefulWidget {
  String text = "";
  Color textColor = Colors.red;

  @protected
  final ValueNotifier<int> _showAlertNotifier = ValueNotifier<int>(0);

  AlertInfoWidget({
    super.key,
    required ValueNotifier<int> newValNotifier,
  }) {
    newValNotifier.addListener(showAlert);
  }

  showAlert() {
    text = AlertInfo().text;
    textColor = AlertInfo().textColor;
    _showAlertNotifier.value++;
  }

  @override
  State<AlertInfoWidget> createState() => _AlertInfoWidgetState();
}

class _AlertInfoWidgetState extends State<AlertInfoWidget> {
  static bool blocked = false;

  TextStyle _style = const TextStyle(
    fontSize: 20,
    color: Colors.red,
    fontWeight: FontWeight.bold,
  );

  @override
  void initState() {
    super.initState();
    widget._showAlertNotifier.addListener(_fadeOut);
  }

  @override
  void dispose() {
    widget._showAlertNotifier.removeListener(_fadeOut);
    super.dispose();
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
