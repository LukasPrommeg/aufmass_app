import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/drawing_zone.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => PlanPageContent();
}

class PlanPageContent extends State<PlanPage> {
  final PaintController _paintController = PaintController();
  final String _roomName = "Raum 1";
  late DrawingZone drawingZone;
  late Widget floatingButton;

  PlanPageContent() {
    drawingZone = DrawingZone(paintController: _paintController);

    _paintController.updateDrawingState.subscribe((args) {switchFloating();});

    floatingButton = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () {
            _paintController.displayTextInputDialog(context);
          },
          child: const Icon(
            Icons.add,
          ),
        ),
      ],
    );
  }

  void switchFloating() {
    setState(() {
      if (_paintController.isDrawing) {
        floatingButton = Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                _paintController.displayTextInputDialog(context);
              },
              child: const Icon(
                Icons.add,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              onPressed: drawingZone.undo,
              child: const Icon(
                Icons.undo,
              ),
            ),
          ],
        );
      }
      else {
        floatingButton = Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                _paintController.displayTextInputDialog(context);
              },
              child: const Icon(
                Icons.add,
              ),
            ),
          ],
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_roomName),
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
      ),
      body: drawingZone,
      floatingActionButton: floatingButton,
    );
  }
}
