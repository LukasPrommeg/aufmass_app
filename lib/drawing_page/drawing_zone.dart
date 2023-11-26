import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';
import 'package:flutter_test_diplom/drawing_page/paint/plancanvas.dart';

class DrawingZone extends StatelessWidget {
  final PaintController paintController;
  final _repaint = ValueNotifier<int>(0);
  final _trafoCont = TransformationController();

  DrawingZone({super.key, required this.paintController});

  void tapUP(TapUpDetails details) {
    paintController.tap(_trafoCont.toScene(details.localPosition));
    _repaint.value++;
  }

  void handleContextMenu(final details) {
    addPoint(_trafoCont.toScene(details.localPosition));
  }

  void addPoint(Offset pos) {
    paintController.drawPoint(pos);
    _repaint.value++;
  }

  void finishArea() {
    paintController.finishArea();
  }

  void undo() {
    paintController.undo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: tapUP,
        onLongPressStart: handleContextMenu,
        onSecondaryTapUp: handleContextMenu,
        child: InteractiveViewer(
          transformationController: _trafoCont,
          minScale: 0.1,
          maxScale: 10,
          child: Stack(
            children: [
              Image.asset(
                "assets/BG.png",
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                opacity: const AlwaysStoppedAnimation(0.25),
              ),
              PlanCanvas(
                paintController: paintController,
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
