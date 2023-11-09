import 'package:flutter/material.dart';
import 'painter.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => PlanPageContent();
}

class PlanPageContent extends State<PlanPage> {
  int _selectedNavBarItem = 0;
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

  void undo() {
    _planPainter.undo();
  }

  void switchBottomNavbarItem(int targetIndex) {
    setState(() {
      _selectedNavBarItem = targetIndex;
    });
  }

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
        SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          child: Icon(
            Icons.undo,
          ),
          onPressed: undo,
        ),
      ],
    );
  }
}
