import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/drawing_page/drawing_zone.dart';
import 'package:flutter_test_diplom/drawing_page/paint/paintcontroller.dart';

class Room {
  String name;
  final DrawingZone drawingZone;
  final PaintController paintController;

  Room({required this.name, required this.drawingZone, required this.paintController});
}

class PlanPage extends StatefulWidget {
  const PlanPage({Key? key}) : super(key: key);

  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late List<Room> rooms;
  late Room currentRoom;

  TextEditingController newRoomController = TextEditingController();
  TextEditingController renameRoomController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize rooms with your desired data
    rooms = [
      Room(
        name: 'Raum 1',
        drawingZone: DrawingZone(paintController: PaintController()),
        paintController: PaintController(),
      ),
      //todo; save and load rooms
      // Add more rooms as needed
    ];

    currentRoom = rooms.first; // Set the initial room
  }

  void switchRoom(Room newRoom) {
    setState(() {
      currentRoom = newRoom;
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
      Navigator.pop(context); // Close the drawer
    }
  }

  void renameRoom() {
    String newName = renameRoomController.text.trim();
    if (newName.isNotEmpty) {
      setState(() {
        currentRoom.name = newName;
      });
      renameRoomController.clear();
      Navigator.pop(context); // Close the drawer
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentRoom.name),
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
      ),
      body: currentRoom.drawingZone,
      floatingActionButton: floatingButton(),
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
                onTap: () {
                  switchRoom(room);
                  Navigator.pop(context); // Close the drawer
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
                            Navigator.pop(context); // Close the dialog
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
                // Set the initial text to the current room's name
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
                            Navigator.pop(context); // Close the dialog
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

  Widget floatingButton() {
    return Column(
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
          onPressed: currentRoom.drawingZone.undo,
          child: const Icon(
            Icons.undo,
          ),
        ),
      ],
    );
  }
}
