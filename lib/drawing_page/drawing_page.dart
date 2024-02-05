import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:aufmass_app/drawing_page/paint/corner.dart';
import 'package:aufmass_app/drawing_page/paint/flaeche.dart';
import 'package:aufmass_app/drawing_page/paint/grundflaeche.dart';
import 'package:aufmass_app/drawing_page/paint/wall.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:aufmass_app/Misc/room.dart';
import 'package:aufmass_app/Einheiten/einheitselector.dart';
import 'package:aufmass_app/drawing_page/paint/paintcontroller.dart';
import 'package:aufmass_app/Misc/pdfexport.dart';
import 'package:aufmass_app/Werkstoffe/Werkstoff_controller.dart';
import '../Einheiten/einheitcontroller.dart';
import '../Misc/WallView.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => PlanPageContent();
}

class PlanPageContent extends State<PlanPage> {
  late Widget floatingButton;
  final List<Room> rooms = [];
  late Room currentRoom;
  WallView? currentWallView=null;
  String projektName = "unnamed";
  late String selectedDropdownValue;
  bool isRightColumnVisible = false;
  bool autoDrawWall=false;

  late var clickedThing=null;

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
            currentRoom.paintController.displayDialog(context);
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

  void switchView(WallView newWallView){
    if(newWallView!=null){
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
  }

  void switchRoom(Room newRoom) {
    currentWallView=null;
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
      clickedThing=null;
    } else {
      switch (clicked.runtimeType) {
        case Corner:
          print("CORNER");
          clickedThing=(clicked as Corner);
          break;
        case Wall:
          print("Wall");
          clickedThing=(clicked as Wall);
          if(currentWallView==null&&clickedThing.wallview==null){  //wenn derzeit nicht in wallview und wall zum erstenmal angelickt wird
            clickedThing.wallview= WallView(name: "Wand",paintController: PaintController());
            clickedThing.wallview.height=2.5;
          }
          setWallHeightController.text = clickedThing.wallview?.height.toString() ?? '';
          break;
        case Flaeche:
          print("Flaeche");
          clickedThing=(clicked as Flaeche);
          break;
        case Grundflaeche:
          print("Grundflaeche");
          clickedThing=(clicked as Grundflaeche);
          break;
        case DrawedWerkstoff:
          print("Werkstoff-${(clicked as DrawedWerkstoff).clickAble.runtimeType}");
          clickedThing=(clicked as DrawedWerkstoff);
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
      if (currentRoom.paintController.isDrawing) {
        floatingButton = Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                currentRoom.paintController.displayDialog(context);
              },
              child: const Icon(
                Icons.add,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              onPressed: currentRoom.paintController.undo,
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
                currentRoom.paintController.displayDialog(context);
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
    PDFExport().generatePDF(projektName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( currentWallView!=null ? '${currentRoom.name} ${currentWallView?.name}' : currentRoom.name),
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
          currentWallView != null?
          Expanded(
            child: currentWallView!.drawingZone,
          ):Expanded(
            child: currentRoom.drawingZone,
          ),
          // Sidemenü rechts
          Visibility(
            visible: isRightColumnVisible,
            child: Container(
              width: 200,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(clickedThing is Flaeche)
                    Text("Fläche: "+EinheitController().convertToSelected(clickedThing.area).toString()+" "+EinheitController().selectedEinheit.name), //have to reload for it to work
                  clickedThing is Wall
                  ? Column(
                    children:[
                      Text(clickedThing.length.toString()),
                      Text(clickedThing.wallview.height.toString()),
                      TextField(
                        controller: setWallHeightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Wandhöhe',
                        ),
                        onChanged: (value) {
                          clickedThing.wallview!.height = double.tryParse(value) ?? 2;setState(() {}); // Trigger a rebuild
                        },
                      ),
                      Text("Wand automatisch zeichnen?"), //Wand kann direkt mit länge * eingestellter höhe gezeichnet werden
                      Checkbox(
                        value: autoDrawWall,
                        onChanged: (bool? value) {
                          setState(() {
                            autoDrawWall = value!;
                          });
                        },
                      ),
                      if(clickedThing.wallview !=null)
                        ElevatedButton(
                          onPressed: () {
                            switchView(clickedThing.wallview);
                          },
                          child: Text('Wand anzeigen'),
                        ),
                    ]
                  )
                  :Container(),
                  if(clickedThing is DrawedWerkstoff)
                    Text(
                      clickedThing?.werkstoff != null
                          ? "Selected Werkstoff: ${clickedThing.werkstoff.name}"
                          : "Select a Werkstoff",
                      style: TextStyle(fontSize: 18),
                    ),
                  if(clickedThing is DrawedWerkstoff)
                  //dropdownbutton with different werkstoffe; unklar: nur Werkstoffe vom selben Typ (wenn Fläche nur Flächen etc)
                    DropdownButton<Werkstoff>(
                      value: WerkstoffController().werkstoffe.first, //cant be: cant have value: clickedThing?.werkstoff ?? WerkstoffController().werkstoffe.first, because clickedThing.werkstoff is not in the list of werkstoffe
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
                  EinheitSelector(
                    setGlobal: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: floatingButton,
      drawer: Drawer(
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
      ),
    );
  }
}
