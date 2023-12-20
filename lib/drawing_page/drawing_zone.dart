import 'package:flutter/material.dart';
import 'package:aufmass_app/drawing_page/paint/background/planbackground.dart';
import 'package:aufmass_app/drawing_page/paint/paintcontroller.dart';
import 'package:aufmass_app/drawing_page/paint/plancanvas.dart';

class DrawingZone extends StatelessWidget {
  final PaintController paintController;
  final PlanBackground planBackground = PlanBackground();
  final _repaint = ValueNotifier<int>(0);
  final _trafoCont = TransformationController();

  DrawingZone({super.key, required this.paintController}) {
    paintController.updateScaleRectEvent.subscribe((args) => updateDrawingScale(args));
  }

  void updateDrawingScale(ScalingData? scale) {
    if (scale != null) {
      planBackground.updateScaleAndRect(scale);
    }
  }

  void tapUP(TapUpDetails details) {
    paintController.tap(_trafoCont.toScene(details.localPosition));
    _repaint.value++;
  }

  void handleContextMenu(final details) {}

  void finishArea() {
    paintController.finishArea();
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
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
              paintController.canvasSize = canvasSize;
              planBackground.updateSize(canvasSize);
              return Stack(
                children: [
                  Image.asset(
                    "assets/BG.png",
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,
                    opacity: const AlwaysStoppedAnimation(0),
                  ),
                  planBackground,
                  PlanCanvas(
                    paintController: paintController,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ]);
  }
}
