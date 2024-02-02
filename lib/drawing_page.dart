import 'package:aufmass_app/2D_Objects/einkerbung.dart';
import 'package:aufmass_app/Misc/alertinfo.dart';
import 'package:aufmass_app/Misc/loadingblur.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:aufmass_app/2D_Objects/corner.dart';
import 'package:aufmass_app/2D_Objects/flaeche.dart';
import 'package:aufmass_app/2D_Objects/grundflaeche.dart';
import 'package:aufmass_app/2D_Objects/wall.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/Room_Parts/room.dart';
import 'package:aufmass_app/Einheiten/einheitselector.dart';
import 'package:aufmass_app/Paint/paintcontroller.dart';
import 'package:aufmass_app/Misc/pdfexport.dart';
import 'package:aufmass_app/Werkstoffe/Werkstoff_controller.dart';
import 'Einheiten/einheitcontroller.dart';
import 'Room_Parts/room_wall.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => PlanPageContent();
}

class PlanPageContent extends State<PlanPage> {
  late Widget floatingButton;
  final List<Room> rooms = [];
  late Room currentRoom;
  RoomWall? currentWallView;
  String projektName = "unnamed";
  late String selectedDropdownValue;
  bool isRightColumnVisible = false;
  bool autoDrawWall = false;

  dynamic clickedThing;

  TextEditingController newRoomController = TextEditingController();
  TextEditingController renameRoomController = TextEditingController();
  TextEditingController renameProjectController = TextEditingController();
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
      setRightColumnVisibility(false);
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
          if (currentWallView == null && !currentRoom.walls.containsKey(clickedThing.uuid)) {
            //wenn derzeit nicht in wallview und wall zum erstenmal angelickt wird
            RoomWall roomWall = RoomWall(wall: clickedThing, height: 2500, name: "Wand", paintController: PaintController());
            currentRoom.walls[clickedThing.uuid] = roomWall;
            AlertInfo().newAlert("generated Wall");
          }
          if (currentRoom.walls.containsKey(clickedThing.uuid)) {
            setWallHeightController.text = currentRoom.walls[clickedThing.uuid]!.height.toString();
          } else {
            AlertInfo().newAlert("text");
          }
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
      setRightColumnVisibility(true);
    }
  }

  void addNewRoom() {
    String newRoomName = newRoomController.text.trim();
    if (newRoomName.isNotEmpty) {
      rooms.add(Room(
        name: newRoomName,
        paintController: PaintController(),
      ));
      switchRoom(rooms.last);
      newRoomController.clear();
      Navigator.pop(context);
    }
  }

  void renameRoom() {
    String newName = renameRoomController.text.trim();
    if (newName.isNotEmpty) {
      setState(() {
        currentRoom.name = newName;
      });
      currentRoom.paintController.roomName = newName;
      renameRoomController.clear();
      Navigator.pop(context);
    }
  }

  void renameProject() {
    String newName = renameProjectController.text.trim();
    setState(() {
      projektName = newName;
    });
    renameRoomController.clear();
    Navigator.pop(context);
  }

  void toggleRightColumnVisibility() {
    setState(() {
      isRightColumnVisible = !isRightColumnVisible;
    });
  }

  void setRightColumnVisibility(bool visible) {
    setState(() {
      isRightColumnVisible = visible;
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

  void createPDF() {
    PDFExport.generatePDF();
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
              _buildRightSideMenu(),
            ],
          ),
          floatingActionButton: floatingButton,
          drawer: _buildLeftSideMenu(),
        ),
        LoadingBlur(),
      ],
    );
  }

  Widget _buildLeftSideMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Projekt Section
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              projektName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          ExpansionTile(
            title: const Text(
              'Projekt',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            shape: const Border(),
            children: [
              ListTile(
                title: const Text('Als PDF exportieren'),
                onTap: createPDF,
              ),
              const Divider(),
              ListTile(
                title: const Text('Projekt umbenennen'),
                onTap: () {
                  // Set the initial text to the current room's name
                  if (projektName != "unnamed") {
                    renameProjectController.text = projektName;
                  }

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Projekt umbenennen'),
                        content: TextField(
                          controller: renameProjectController,
                          decoration: const InputDecoration(labelText: 'Projektname'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Abbrechen'),
                          ),
                          TextButton(
                            onPressed: () {
                              renameProject();
                            },
                            child: const Text('Umbenennen'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const Divider(),
          // Rooms Section
          ExpansionTile(
            title: const Text(
              'Räume',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            shape: const Border(),
            children: [
              for (var room in rooms)
                ListTile(
                  title: Text(room.name),
                  tileColor: room == currentRoom ? Colors.grey[300] : null,
                  onTap: () {
                    switchRoom(room);
                    Navigator.pop(context);
                  },
                ),
              const Divider(),
              ListTile(
                title: const Text('Raum hinzufügen'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Raum hinzufügen'),
                        content: TextField(
                          controller: newRoomController,
                          decoration: const InputDecoration(labelText: 'Name des Raumes'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Abbrechen'),
                          ),
                          TextButton(
                            onPressed: () {
                              addNewRoom();
                            },
                            child: const Text('Hinzufügen'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Raum umbenennen'),
                onTap: () {
                  // Set the initial text to the current room's name
                  renameRoomController.text = currentRoom.name;

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Raum umbenennen'),
                        content: TextField(
                          controller: renameRoomController,
                          decoration: const InputDecoration(labelText: 'Name des Raumes'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Abbrechen'),
                          ),
                          TextButton(
                            onPressed: () {
                              renameRoom();
                            },
                            child: const Text('Hinzufügen'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightSideMenu() {
    // Sidemenü rechts
    return Visibility(
      visible: isRightColumnVisible,
      child: Container(
        width: 250,
        color: Colors.grey[200],
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  clickedThing.runtimeType.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                EinheitSelector(
                  setGlobal: true,
                ),
                const Divider(),
              ],
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  if (clickedThing is Flaeche) Text("Fläche: ${EinheitController().convertToSelected(clickedThing.area)} ${EinheitController().selectedEinheit.name}"), //have to reload for it to work
                  clickedThing is Wall && currentWallView == null
                      ? Column(children: [
                          Text(clickedThing.length.toString()),
                          Text(currentRoom.walls[clickedThing.uuid]!.height.toString()),
                          TextField(
                            controller: setWallHeightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Wandhöhe',
                            ),
                            onChanged: (value) {
                              //TODO: change Wall height
                              //currentRoom.walls[clickedThing.uuid]!.height = double.tryParse(value) ?? 2;
                              setState(() {}); // Trigger a rebuild
                            },
                          ),
                          const Text("Wand automatisch zeichnen?"), //Wand kann direkt mit länge * eingestellter höhe gezeichnet werden
                          Checkbox(
                            value: autoDrawWall,
                            onChanged: (bool? value) {
                              setState(() {
                                autoDrawWall = value!;
                              });
                            },
                          ),
                          if (currentRoom.walls.containsKey(clickedThing.uuid))
                            ElevatedButton(
                              onPressed: () {
                                switchView(currentRoom.walls[clickedThing.uuid]!);
                              },
                              child: const Text('Wand anzeigen'),
                            ),
                        ])
                      : Container(),
                  if (clickedThing is DrawedWerkstoff)
                    Text(
                      clickedThing?.werkstoff != null ? "Selected Werkstoff: ${clickedThing.werkstoff.name}" : "Select a Werkstoff",
                      style: const TextStyle(fontSize: 18),
                    ),
                  if (clickedThing is DrawedWerkstoff)
                    //dropdownbutton with different werkstoffe; unklar: nur Werkstoffe vom selben Typ (wenn Fläche nur Flächen etc)
                    DropdownButton<Werkstoff>(
                      value: WerkstoffController()
                          .werkstoffe
                          .first, //cant be: cant have value: clickedThing?.werkstoff ?? WerkstoffController().werkstoffe.first, because clickedThing.werkstoff is not in the list of werkstoffe
                      onChanged: (Werkstoff? newValue) {
                        setState(() {
                          if (clickedThing != null) {
                            clickedThing.werkstoff = newValue;
                          }
                        });
                      },
                      items: WerkstoffController().werkstoffe.map<DropdownMenuItem<Werkstoff>>((Werkstoff werkstoff2) {
                        print("Creating DropdownMenuItem for Werkstoff: $werkstoff2");
                        return DropdownMenuItem<Werkstoff>(
                          value: werkstoff2,
                          child: Text(werkstoff2.name),
                        );
                      }).toList(),
                    ),
                  if (clickedThing is Grundflaeche)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ExpansionTile(
                          title: Text("Einkerbungen"),
                          shape: const Border(),
                          children: [
                            for (Einkerbung einkerbung in (clickedThing as Grundflaeche).einkerbungen)
                              ListTile(
                                title: Text(einkerbung.name),
                                onTap: () {
                                  clickedThing = einkerbung;
                                  setRightColumnVisibility(true);
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  if (clickedThing is Einkerbung)
                    Column(
                      children: [
                        const Divider(),
                        ExpansionTile(
                          title: Text("Werkstoffe"),
                          shape: const Border(),
                          children: [
                            for (DrawedWerkstoff werkstoff in (clickedThing as Einkerbung).overlappingWerkstoffe)
                              ListTile(
                                enableFeedback: false,
                                iconColor: werkstoff.werkstoff.color,
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(werkstoff.werkstoff.name),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.edit_square),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  //clickedThing = einkerbung;
                                  setRightColumnVisibility(true);
                                },
                                leading: Icon(Icons.circle),
                              ),
                          ],
                        ),
                        const Divider(),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
