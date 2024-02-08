import 'package:aufmass_app/PlanPage/Misc/pdfexport.dart';
import 'package:aufmass_app/PlanPage/Paint/paintcontroller.dart';
import 'package:aufmass_app/PlanPage/Room_Parts/room.dart';
import 'package:aufmass_app/PlanPage/planpage.dart';
import 'package:flutter/material.dart';

class LeftPlanpageSidemenu extends StatefulWidget {
  late String projektName;
  final List<Room> rooms; //TODO: LADEN AUS DB
  final PlanPageContent planPage;

  LeftPlanpageSidemenu({
    super.key,
    required this.projektName,
    required this.rooms,    
    required this.planPage,
  });

  @override
  State<LeftPlanpageSidemenu> createState() => _LeftPlanpageSidemenuState();
}


class _LeftPlanpageSidemenuState extends State<LeftPlanpageSidemenu> {

  TextEditingController newRoomController = TextEditingController();
  TextEditingController renameRoomController = TextEditingController();
  TextEditingController renameProjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              widget.projektName,
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
                  if (widget.projektName != "unnamed") {
                    renameProjectController.text = widget.projektName;
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
              for (var room in widget.rooms)
                ListTile(
                  title: Text(room.name),
                  tileColor: room == widget.planPage.currentRoom ? Colors.grey[300] : null,
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
                  renameRoomController.text = widget.planPage.currentRoom.name;

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
  void createPDF() {
    PDFExport().generatePDF(widget.projektName);
  }
  void renameProject() {
    String newName = renameProjectController.text.trim();
    setState(() {
      widget.projektName = newName;
    });
    renameRoomController.clear();
    Navigator.pop(context);
  }
  void renameRoom() {
    String newName = renameRoomController.text.trim();
    if (newName.isNotEmpty) {
      setState(() {
        widget.planPage.currentRoom.name = newName;
      });
      widget.planPage.currentRoom.paintController.roomName = newName;
      renameRoomController.clear();
      Navigator.pop(context);
    }
  }
  void addNewRoom() {
    setState(() {
      String newRoomName = newRoomController.text.trim();
    if (newRoomName.isNotEmpty) {
      widget.rooms.add(Room(
        name: newRoomName,
        paintController: PaintController(),
      ));
      switchRoom(widget.rooms.last);
      newRoomController.clear();
      Navigator.pop(context);
    }
    });
  }
  void switchRoom(Room newRoom) {
    widget.planPage.switchRoom(newRoom);
  }
}
