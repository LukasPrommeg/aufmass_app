import 'package:aufmass_app/PlanPage/Paint/paintcontroller.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/Background/planbackground.dart';
import 'package:aufmass_app/PlanPage/Paint/plancanvas.dart';

class DrawingZone extends StatelessWidget {
  final PaintController paintController;
  final PlanBackground planBackground = PlanBackground();
  final _repaint = ValueNotifier<int>(0);
  final _trafoCont = TransformationController();

  DrawingZone({super.key, required this.paintController}) {
    paintController.updateScaleRectEvent
        .subscribe((args) => updateDrawingScale(args));
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

  void finishArea() {
    paintController.finishArea();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: tapUP,
          //onLongPressStart: handleContextMenu,
          //onSecondaryTapUp: handleContextMenu,
          child: InteractiveViewer(
            transformationController: _trafoCont,
            minScale: 0.01,
            maxScale: 100,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                Size canvasSize =
                    Size(constraints.maxWidth, constraints.maxHeight);
                paintController.canvasSize = canvasSize;
                planBackground.updateSize(canvasSize);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: planBackground,
                    ),
                    Positioned.fill(
                      child: PlanCanvas(
                        paintController: paintController,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
