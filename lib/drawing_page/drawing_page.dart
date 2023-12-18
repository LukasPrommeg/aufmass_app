import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/Misc/Room.dart';
import 'package:flutter_test_diplom/drawing_page/drawing_zone.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => PlanPageContent();
}

class PlanPageContent extends State<PlanPage> {
  /*final PaintController _paintController = PaintController();
  final String _roomName = "Raum 1";
  late DrawingZone drawingZone;*/
  late Widget floatingButton;

  late List<Room> rooms;
  late Room currentRoom;
  late String selectedDropdownValue;
  bool isRightColumnVisible = true;

  TextEditingController newRoomController = TextEditingController();
  TextEditingController renameRoomController = TextEditingController();

  @override
  void initState() {
    super.initState();

    rooms = [
      Room(
        name: 'Raum 1',
        drawingZone: DrawingZone(paintController: PaintController()),
        paintController: PaintController(),
      ),
      // todo: save and load rooms
    ];

    currentRoom = rooms.first;
    selectedDropdownValue = 'Option 1';

    currentRoom.paintController.updateDrawingState.subscribe((args) {
      switchFloating();
    });

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
      currentRoom = newRoom;

      switchFloating();
    });
  }

  void addNewRoom() {
    String newRoomName = newRoomController.text.trim();
    if (newRoomName.isNotEmpty) {
      rooms.add(Room(
        name: newRoomName,
        drawingZone: DrawingZone(paintController: PaintController()),
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

  /*PlanPageContent() {

    drawingZone = DrawingZone(paintController: _paintController);

    
  }*/

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
                color: Colors.blue,
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
              title: Text('Add New Room'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Enter Room Name'),
                      content: TextField(
                        controller: newRoomController,
                        decoration: InputDecoration(labelText: 'Room Name'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            addNewRoom();
                          },
                          child: Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: Text('Rename Room'),
              onTap: () {
                renameRoomController.text = currentRoom.name;

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Enter New Room Name'),
                      content: TextField(
                        controller: renameRoomController,
                        decoration: InputDecoration(labelText: 'New Room Name'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            renameRoom();
                          },
                          child: Text('Rename'),
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
