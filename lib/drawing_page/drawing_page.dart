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
  final String _title = "Raum 1";
  late DrawingZone drawingZone;

  PlanPageContent() {
    drawingZone = DrawingZone(paintController: _paintController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
      ),
      body: drawingZone,
      floatingActionButton: floatingButton(),
    );
  }

  Widget floatingButton() {
    return Column(
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
}
