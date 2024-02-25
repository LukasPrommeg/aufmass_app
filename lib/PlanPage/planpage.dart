import 'package:aufmass_app/PlanPage/Misc/alertinfo.dart';
import 'package:aufmass_app/PlanPage/Misc/inverted_quater_circle.dart';
import 'package:aufmass_app/PlanPage/Misc/loadingblur.dart';
import 'package:aufmass_app/PlanPage/Paint/paintcontroller.dart';
import 'package:aufmass_app/PlanPage/SidemenuInputs/inputhandler.dart';
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

enum FloatingButtonState {
  none,
  undo,
  add,
}

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
  Widget? floatingButton;

  //Controllers
  TextEditingController newRoomController = TextEditingController();
  TextEditingController setWallHeightController = TextEditingController();

  late Room currentRoom;
  RoomWall? currentWallView;
  //late String selectedDropdownValue;

  dynamic clickedThing;

  @override
  void initState() {
    super.initState();

    //TODO: save and load rooms

    currentRoom = widget.projekt.rooms.first;
    switchRoom(currentRoom);

    setState(() {
      leftSidemenu = LeftPlanpageSidemenu(
        projekt: widget.projekt,
        selectedIndex: widget.projekt.rooms.indexOf(currentRoom),
        switchRoomCallBack: (newRoom) => switchRoom(newRoom),
      );
    });
  }

  void switchView(RoomWall newWallView) {
    setState(() {
      newWallView.paintController.refreshMenuElements.unsubscribeAll();
      newWallView.paintController.clickedEvent.unsubscribe((args) {});
      currentWallView = newWallView;
      currentRoom.paintController.refreshMenuElements.subscribe((args) => toggleMenuElements());
      currentWallView!.paintController.clickedEvent.subscribe((args) => handleClickedEvent(args));
      toggleMenuElements();
    });
  }

  void switchRoom(Room newRoom) {
    //TODO: HiveOperator.saveAll oda so
    currentWallView = null;
    setState(() {
      newRoom.paintController.refreshMenuElements.unsubscribeAll();
      newRoom.paintController.clickedEvent.unsubscribe((args) {});
      currentRoom = newRoom;
      currentRoom.paintController.refreshMenuElements.subscribe((args) => toggleMenuElements());
      currentRoom.paintController.clickedEvent.subscribe((args) => handleClickedEvent(args));
      toggleMenuElements();

      leftSidemenu = LeftPlanpageSidemenu(
        key: UniqueKey(),
        projekt: widget.projekt,
        selectedIndex: widget.projekt.rooms.indexOf(currentRoom),
        switchRoomCallBack: (newRoom) => switchRoom(newRoom),
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
      InputHandler inputHandler = currentRoom.paintController.inputHandler;

      if (currentWallView != null) {
        isWallView = true;
        inputHandler = currentWallView!.paintController.inputHandler;
      }

      side = RightPlanpageSidemenu(
        clickedThing: clickedThing,
        isWallView: isWallView,
        generatedWalls: currentRoom.walls.keys.toList(),
        inputHandler: inputHandler,
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
    InputHandler inputHandler = currentRoom.paintController.inputHandler;

    if (currentWallView != null) {
      isWallView = true;
      inputHandler = currentWallView!.paintController.inputHandler;
    }

    setState(() {
      rightSidemenu = RightPlanpageSidemenu(
        key: UniqueKey(),
        clickedThing: clickedThing,
        isWallView: isWallView,
        generatedWalls: currentRoom.walls.keys.toList(),
        inputHandler: inputHandler,
        onRepaintNeeded: repaintDrawing,
        onWallViewGenerated: (roomWall) => openWallViewCallback(roomWall),
      );
    });
  }

  void toggleMenuElements() {
    FloatingButtonState state = FloatingButtonState.add;
    bool openRightMenu = false;

    PaintController currentController = currentRoom.paintController;
    if (currentWallView != null) {
      currentController = currentWallView!.paintController;
    }

    if (currentController.inputHandler.currentlyHandling == CurrentlyHandling.lines) {
      state = FloatingButtonState.undo;
      openRightMenu = true;
    } else if (currentController.inputHandler.currentlyHandling == CurrentlyHandling.startingPoint) {
      state = FloatingButtonState.none;
      openRightMenu = true;
    }

    setState(() {
      switch (state) {
        case FloatingButtonState.add:
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
          break;
        case FloatingButtonState.undo:
          floatingButton = Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
          break;
        default:
          floatingButton = null;
          break;
      }
      if (rightSidemenu != null) {
        rightSidemenu!.unsubscribeInputHandler();
      }
      if (openRightMenu || rightSidemenu != null) {
        enableRightSidemenu(null);
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
                      child: AlertInfo().widget(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const InvertedCorner(
                            corner: Corner.rightBottom,
                            radius: 25,
                            color: Colors.deepPurple,
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: const BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                bottomLeft: Radius.circular(25),
                              ),
                            ),
                            child: IconButton(
                              color: Colors.white,
                              onPressed: () => toggleRightColumnVisibility(),
                              icon: rightSidemenu == null ? const Icon(Icons.arrow_back_ios_new_rounded) : const Icon(Icons.arrow_forward_ios_rounded),
                            ),
                          ),
                          const InvertedCorner(
                            corner: Corner.rightTop,
                            radius: 25,
                            color: Colors.deepPurple,
                          ),
                        ],
                      ),
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
}
