import 'package:aufmass_app/PlanPage/Misc/alertinfo.dart';
import 'package:aufmass_app/PlanPage/Misc/loadingblur.dart';
import 'package:aufmass_app/PlanPage/li_sidemenu.dart';
import 'package:aufmass_app/PlanPage/re_sidemenu.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/corner.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/flaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/grundflaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/wall.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/PlanPage/Room_Parts/room.dart';
import 'package:aufmass_app/PlanPage/Paint/paintcontroller.dart';
import 'package:aufmass_app/PlanPage/Misc/pdfexport.dart';
import 'Room_Parts/room_wall.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => PlanPageContent();
}

class PlanPageContent extends State<PlanPage> {
  RightPlanpageSidemenu? rightSidemenu;
  LeftPlanpageSidemenu? leftSidemenu;
  late Widget floatingButton;
  final List<Room> rooms = []; //TODO: LADEN AUS DB
  late Room currentRoom;
  RoomWall? currentWallView;
  late String selectedDropdownValue;
  bool isRightColumnVisible = false;
  bool autoDrawWall = false;

  dynamic clickedThing;

  TextEditingController newRoomController = TextEditingController();
  TextEditingController setWallHeightController = TextEditingController();

  @override
  void initState() {
    super.initState();


    rooms.add(Room(
      name: 'Raum 1',
      paintController: PaintController(),
    ));
    //TODO: save and load rooms

    currentRoom = rooms.first;
    switchRoom(currentRoom);

    selectedDropdownValue = 'Option 1';

    floatingButton = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
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
          onPressed: () {
            currentRoom.paintController.roomName = "testwohnzimmer";
          },
          child: const Icon(
            Icons.polyline_rounded,
          ),
        ),
      ],
    );

    setState((){
      leftSidemenu=LeftPlanpageSidemenu(projektName: "unnamed",rooms: rooms, planPage: this,);
    });

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
    currentWallView = null;
    setState(() {
      newRoom.paintController.updateDrawingState.unsubscribe((args) {});
      newRoom.paintController.clickedEvent.unsubscribe((args) {});
      currentRoom = newRoom;
      currentRoom.paintController.updateDrawingState.subscribe((args) {
        switchFloating();
      });
      currentRoom.paintController.clickedEvent.subscribe((args) => handleClickedEvent(args));
      switchFloating();
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
        case Corner:
          print("CORNER");
          clickedThing = (clicked as Corner);
          break;
        case Wall:
          print("Wall-${(clicked as Wall).uuid}");
          clickedThing = clicked;
          break;
        case Flaeche:
          print("Flaeche");
          clickedThing = (clicked as Flaeche);
          break;
        case Grundflaeche:
          print("Grundflaeche");
          clickedThing = (clicked as Grundflaeche);
          break;
        case DrawedWerkstoff:
          print("Werkstoff-${(clicked as DrawedWerkstoff).clickAble.runtimeType}");
          clickedThing = clicked;
          break;
        default:
          print("Shouldn't be possible");
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
                icon: Icon(isRightColumnVisible ? Icons.visibility_off : Icons.visibility),
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
                    currentWallView != null ? currentWallView!.drawingZone : currentRoom.drawingZone,
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
    if (currentRoom.walls.containsKey(roomWall.wall.uuid)) {
      switchView(currentRoom.walls[roomWall.wall.uuid]!);
    } else {
      currentRoom.walls[roomWall.wall.uuid] = roomWall;
      switchView(currentRoom.walls[roomWall.wall.uuid]!);
    }
    setState(() {
      rightSidemenu = null;
    });
  }
}
