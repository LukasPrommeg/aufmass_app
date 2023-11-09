import 'package:flutter/material.dart';
import 'painter.dart';

class Zeichenflaeche extends StatefulWidget {
  const Zeichenflaeche({super.key});

  @override
  State<Zeichenflaeche> createState() => _ZeichenflaecheState();
}

class _ZeichenflaecheState extends State<Zeichenflaeche> {
  final _trafoCont = TransformationController();
  final _paintKey = GlobalKey();
  MyPainter _planPainter = MyPainter();
  String _title = "-";

  void tapUP(TapUpDetails details) {
    updateTitle(
        "TAP AT " + _trafoCont.toScene(details.localPosition).toString());
  }

  void handleContextMenu(final details) {
    updateTitle(
        "CONTEXT AT " + _trafoCont.toScene(details.localPosition).toString());
    addPoint(details.localPosition);
  }

  void updateTitle(String title) {
    setState(() {
      _title = title;
    });
  }

  void addPoint(Offset pos) {
    _planPainter.addPoint(pos);
    setState(() {});
  }

  void finishArea() {
    _planPainter.finishArea();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
        onTapUp: tapUP,
        onLongPressStart: handleContextMenu,
        onSecondaryTapUp: handleContextMenu,
        child: InteractiveViewer(
          transformationController: _trafoCont,
          minScale: 0.1,
          maxScale: 10,
          child: Stack(
            children: [
              Center(
                child: Text("Debug " + _title),
              ),
              CustomPaint(
                key: _paintKey,
                painter: _planPainter,
              ),
              Image.asset(
                "assets/BG.jpg",
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                opacity: const AlwaysStoppedAnimation(0.25),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget floatingButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          child: Icon(
            Icons.flag,
          ),
          onPressed: finishArea,
        ),
      ],
    );
  }
}
