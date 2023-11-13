import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/paint/linepainter.dart';
import 'package:flutter_test_diplom/paint/paintcontroller.dart';
import 'package:flutter_test_diplom/paint/polypainter.dart';
import 'package:flutter_test_diplom/paint/plancanvas.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => PlanPageContent();
}

class PlanPageContent extends State<PlanPage> {
  //int _selectedNavBarItem = 0;
  final _trafoCont = TransformationController();
  final PaintController _paintController =
      PaintController(polyPainter: PolyPainter(), linePainter: LinePainter());
  String _title = "-";

  void tapUP(TapUpDetails details) {
    updateTitle(
        "TAP AT " + _trafoCont.toScene(details.localPosition).toString());
    _paintController.tap(_trafoCont.toScene(details.localPosition));
  }

  void handleContextMenu(final details) {
    updateTitle(
        "CONTEXT AT " + _trafoCont.toScene(details.localPosition).toString());
    addPoint(_trafoCont.toScene(details.localPosition));
  }

  void updateTitle(String title) {
    setState(() {
      _title = title;
    });
  }

  void addPoint(Offset pos) {
    _paintController.drawPoint(pos);
    setState(() {});
  }

  void finishArea() {
    _paintController.finishArea();
  }

  void undo() {
    _paintController.undo();
  }

  /*void switchBottomNavbarItem(int targetIndex) {
    setState(() {
      _selectedNavBarItem = targetIndex;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text("Fliesenleger"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
      ),*/
      body: zeichenflaeche(),
      floatingActionButton: floatingButton(),
      /*bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        currentIndex: _selectedNavBarItem,
        selectedItemColor: Colors.black,
        onTap: switchBottomNavbarItem,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.purple,
      ),*/
    );
  }

  Widget zeichenflaeche() {
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
                paintController: _paintController,
              ),
              Center(
                child: Text("Debug " + _title),
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
          onPressed: finishArea,
          child: const Icon(
            Icons.flag,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          onPressed: undo,
          child: const Icon(
            Icons.undo,
          ),
        ),
      ],
    );
  }
}
