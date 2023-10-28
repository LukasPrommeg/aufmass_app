import 'package:flutter/material.dart';

class Zeichenflaeche extends StatefulWidget {
  const Zeichenflaeche({super.key});

  @override
  State<Zeichenflaeche> createState() => _ZeichenflaecheState();
}

class _ZeichenflaecheState extends State<Zeichenflaeche> {
  final _trafoCont = TransformationController();

  String _title = "-";

  void tapUP(TapUpDetails details) {
    updateTitle(
        "TAP AT " + _trafoCont.toScene(details.localPosition).toString());
  }

  void handleContextMenu(final details) {
    updateTitle(
        "CONTEXT AT " + _trafoCont.toScene(details.localPosition).toString());
  }

  void updateTitle(String title) {
    setState(() {
      _title = title;
    });
  }

  void addPoint() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            /*Canvas(),

                  CustomPaint(
                    painter: PolygonPainter(),
                  ),*/
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
    );
  }
}
