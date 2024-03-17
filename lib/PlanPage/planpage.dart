import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:aufmass_app/PlanPage/Misc/alertinfo.dart';
import 'package:aufmass_app/PlanPage/Misc/loadingblur.dart';
import 'package:aufmass_app/PlanPage/Paint/polypainter.dart';
import 'package:aufmass_app/PlanPage/li_sidemenu.dart';
import 'package:aufmass_app/PlanPage/projekt.dart';
import 'package:aufmass_app/PlanPage/re_sidemenu.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/punkt.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/flaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/grundflaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/linie.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/Room_Parts/room.dart';
import 'Room_Parts/room_wall.dart';
import 'package:flutter_to_pdf/flutter_to_pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key, required this.projekt});

  final Projekt projekt;

  @override
  State<PlanPage> createState() => PlanPageContent();
}

class PlanPageContent extends State<PlanPage> {
  //Widgets
  RightPlanpageSidemenu? rightSidemenu;
  LeftPlanpageSidemenu? leftSidemenu;
  late Widget floatingButton;

  //Controllers
  TextEditingController newRoomController = TextEditingController();
  TextEditingController setWallHeightController = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();

  late Room currentRoom;
  RoomWall? currentWallView;

  final ExportDelegate exportDelegate = ExportDelegate();

  //late String selectedDropdownValue;

  dynamic clickedThing;

  @override
  void initState() {
    super.initState();

    //TODO: save and load rooms

    currentRoom = widget.projekt.rooms.first;
    switchRoom(currentRoom);

    floatingButton = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "AddWall",
          onPressed: () {
            if (currentWallView != null) {
              currentWallView!.paintController.displayDialog(context);
            } else {
              currentRoom.paintController.displayDialog(context);
            }
          },
          child: const Icon(
            Icons.add,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          heroTag: "drawTest",
          onPressed: () {
            currentRoom.name = "testwohnzimmer";
          },
          child: const Icon(
            Icons.polyline_rounded,
          ),
        ),
      ],
    );

    setState(() {
      leftSidemenu = LeftPlanpageSidemenu(
        key:UniqueKey(),
        projekt: widget.projekt,
        selectedIndex: widget.projekt.rooms.indexOf(currentRoom),
        switchRoomCallBack: (newRoom) => switchRoom(newRoom),
        planPage: this,
        exportDelegate: exportDelegate,
      );
    });
  }
  Projekt getProject() {
    return widget.projekt;
  }

  void switchView(RoomWall newWallView) {
    setState(() {
      newWallView.paintController.updateDrawingState.unsubscribe((args) {});
      newWallView.paintController.clickedEvent.unsubscribe((args) {});
      currentWallView = newWallView;
      currentWallView!.paintController.updateDrawingState.subscribe((args) {
        switchFloating();
      });
      currentWallView!.paintController.clickedEvent.subscribe((args) => handleClickedEvent(args));
      switchFloating();
    });
  }

  void switchRoom(Room newRoom) {
    //TODO: HiveOperator.saveAll oda so
    currentWallView = null;
    setState(() {
      newRoom.paintController.updateDrawingState.unsubscribe((args) {});
      newRoom.paintController.clickedEvent.unsubscribe((args) {});
      currentRoom = newRoom;
      currentRoom.paintController.updateDrawingState.subscribe((args) => switchFloating());
      currentRoom.paintController.clickedEvent.subscribe((args) => handleClickedEvent(args));
      switchFloating();

      leftSidemenu = LeftPlanpageSidemenu(
        key: UniqueKey(),
        projekt: widget.projekt,
        selectedIndex: widget.projekt.rooms.indexOf(currentRoom),
        switchRoomCallBack: (newRoom) => switchRoom(newRoom),
        planPage: this,
        exportDelegate: exportDelegate,
      );
    });
  }

  void handleClickedEvent(EventArgs? clicked) {
    if (clicked == null) {
      setState(() {
        rightSidemenu = null;
      });
      clickedThing = null;
    } else {
      switch (clicked.runtimeType) {
        case Punkt:
          clickedThing = (clicked as Punkt);
          break;
        case Linie:
          clickedThing = clicked;
          break;
        case Flaeche:
          clickedThing = (clicked as Flaeche);
          break;
        case Grundflaeche:
          clickedThing = (clicked as Grundflaeche);
          break;
        case DrawedWerkstoff:
          clickedThing = clicked;
          break;
        default:
          break;
      }
      enableRightSidemenu(clickedThing);
    }
  }

  void toggleRightColumnVisibility() {
    RightPlanpageSidemenu? side;

    if (rightSidemenu == null) {
      bool isWallView = false;

      if (currentWallView != null) {
        isWallView = true;
      }

      side = RightPlanpageSidemenu(
        clickedThing: clickedThing,
        isWallView: isWallView,
        generatedWalls: currentRoom.walls.keys.toList(),
        onRepaintNeeded: repaintDrawing,
        onWallViewGenerated: (roomWall) => openWallViewCallback(roomWall),
      );
    }
    setState(() {
      rightSidemenu = side;
    });
  }

  void enableRightSidemenu(dynamic clicked) {
    bool isWallView = false;

    if (currentWallView != null) {
      isWallView = true;
    }

    setState(() {
      rightSidemenu = RightPlanpageSidemenu(
        key: UniqueKey(),
        clickedThing: clickedThing,
        isWallView: isWallView,
        generatedWalls: currentRoom.walls.keys.toList(),
        onRepaintNeeded: repaintDrawing,
        onWallViewGenerated: (roomWall) => openWallViewCallback(roomWall),
      );
    });
  }

  void switchFloating() {
    setState(() {
      if (currentRoom.paintController.isDrawing || (currentWallView != null && currentWallView!.paintController.isDrawing)) {
        floatingButton = Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "AddWall",
              onPressed: () {
                if (currentWallView != null) {
                  currentWallView!.paintController.displayDialog(context);
                } else {
                  currentRoom.paintController.displayDialog(context);
                }
              },
              child: const Icon(
                Icons.add,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              heroTag: "Undo",
              onPressed: () {
                if (currentWallView != null) {
                  currentWallView!.paintController.undo();
                } else {
                  currentRoom.paintController.undo();
                }
              },
              child: const Icon(
                Icons.undo,
              ),
            ),
          ],
        );
      } else {
        floatingButton = Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "AddWall",
              onPressed: () {
                if (currentWallView != null) {
                  currentWallView!.paintController.displayDialog(context);
                } else {
                  currentRoom.paintController.displayDialog(context);
                }
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

  void repaintDrawing() {
    if (currentWallView != null) {
      currentWallView!.paintController.repaint();
    } else {
      currentRoom.paintController.repaint();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Row(
              children: [
                Text(currentRoom.name),
                if (currentWallView != null) ...[
                  const SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    onPressed: () {
                      switchRoom(currentRoom);
                    },
                    tooltip: "Zurück",
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(currentWallView!.name),
                ]
              ],
            ),
            foregroundColor: Colors.white,
            backgroundColor: Colors.purple,
            actions: [
              IconButton(
                onPressed: () {
                  //TODO: HiveOperator.saveAll oda so
                  AlertInfo().newAlert("Speichern..", textColor: Colors.green);
                },
                icon: const Icon(Icons.save_outlined),
              ),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                icon: Icon(rightSidemenu == null ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleRightColumnVisibility,
              ),
            ],
          ),
          body: Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    currentWallView != null ? currentWallView!.drawRoomPart() : currentRoom.drawRoomPart(),
                    SizedBox(
                      height: 100,
                      child: AlertInfo(),
                    ),
                  ],
                ),
              ),
              if (rightSidemenu != null) rightSidemenu!,
            ],
          ),
          floatingActionButton: floatingButton,
          drawer: leftSidemenu,
        ),
        LoadingBlur(),
      ],
    );
  }

  void openWallViewCallback(RoomWall roomWall) {
    if (currentRoom.walls.containsKey(roomWall.baseLine.uuid)) {
      switchView(currentRoom.walls[roomWall.baseLine.uuid]!);
    } else {
      currentRoom.walls[roomWall.baseLine.uuid] = roomWall;
      switchView(currentRoom.walls[roomWall.baseLine.uuid]!);
    }
    setState(() {
      rightSidemenu = null;
    });
  }

  Room getCurrentRoom(){
    return currentRoom;
  }
}


