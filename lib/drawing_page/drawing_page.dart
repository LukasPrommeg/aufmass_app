import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/Misc/Room.dart';
import 'package:flutter_test_diplom/Misc/einheitselector.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class PlanPage extends StatefulWidget {
  /*final List<Room> rooms = [];
  late Room currentRoom;

  PlanPage({super.key}) {}*/

  @override
  State<PlanPage> createState() => PlanPageContent();
}

class PlanPageContent extends State<PlanPage> {
  late Widget floatingButton;
  final List<Room> rooms = [];
  late Room currentRoom;
  late String selectedDropdownValue;
  bool isRightColumnVisible = false;

  TextEditingController newRoomController = TextEditingController();
  TextEditingController renameRoomController = TextEditingController();

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
            currentRoom.paintController.displayTextInputDialog(context);
          },
          child: const Icon(
            Icons.add,
          ),
        ),
      ],
    );
  }

  void switchRoom(Room newRoom) {
    setState(() {
      newRoom.paintController.updateDrawingState.unsubscribe((args) {});
      currentRoom = newRoom;
      currentRoom.paintController.updateDrawingState.subscribe((args) {
        switchFloating();
      });
      switchFloating();
    });
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
      renameRoomController.clear();
      Navigator.pop(context);
    }
  }

  void toggleRightColumnVisibility() {
    setState(() {
      isRightColumnVisible = !isRightColumnVisible;
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
                currentRoom.paintController.displayTextInputDialog(context);
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
                currentRoom.paintController.displayTextInputDialog(context);
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
        title: Text(currentRoom.name),
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(
                isRightColumnVisible ? Icons.visibility_off : Icons.visibility),
            onPressed: toggleRightColumnVisibility,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
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
                  // Dropdown menü
                  DropdownButton<String>(
                    value:
                        selectedDropdownValue, //sollte selected.werkstoff werden
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDropdownValue = newValue!;
                      });
                    },
                    items: <String>[
                      'Option 1',
                      'Werkstoff 2',
                      'Werkstoff 3',
                      'Werkstoff 4'
                    ] //sollte zur Wirklichen Liste von Werkstoffen  (WTF ERROR WENN NICHT "Option")
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  Text('Länge: TEST'),
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text('Räume'),
            ),
            for (var room in rooms)
              ListTile(
                title: Text(room.name),
                tileColor: room == currentRoom ? Colors.grey[300] : null,
                onTap: () {
                  switchRoom(room);
                  Navigator.pop(context);
                },
              ),
            Divider(),
            ListTile(
              title: Text('Raum hinzufügen'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Raum hinzufügen'),
                      content: TextField(
                        controller: newRoomController,
                        decoration:
                            InputDecoration(labelText: 'Name des Raumes'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Abbrechen'),
                        ),
                        TextButton(
                          onPressed: () {
                            addNewRoom();
                          },
                          child: Text('Hinzufügen'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: Text('Raum umbenennen'),
              onTap: () {
                renameRoomController.text = currentRoom.name;

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Raum umbenennen'),
                      content: TextField(
                        controller: renameRoomController,
                        decoration:
                            InputDecoration(labelText: 'Name des Raumes'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Abbrechen'),
                        ),
                        TextButton(
                          onPressed: () {
                            renameRoom();
                          },
                          child: Text('Umbenennen'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
