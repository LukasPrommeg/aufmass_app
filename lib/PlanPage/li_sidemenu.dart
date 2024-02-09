import 'package:aufmass_app/PlanPage/Misc/pdfexport.dart';
import 'package:aufmass_app/PlanPage/Room_Parts/room.dart';
import 'package:aufmass_app/PlanPage/projekt.dart';
import 'package:flutter/material.dart';

typedef SwitchRoomCallBack = void Function(Room);

class LeftPlanpageSidemenu extends StatefulWidget {
  final Projekt projekt;
  final int selectedIndex;
  final SwitchRoomCallBack switchRoomCallBack;

  const LeftPlanpageSidemenu({
    super.key,
    required this.projekt,
    required this.selectedIndex,
    required this.switchRoomCallBack,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    //TODO: HiveOperator.saveAll oda so
                    Navigator.pushReplacementNamed(
                      context,
                      "/home",
                    );
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.projekt.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
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
                  if (widget.projekt.name != "unnamed") {
                    renameProjectController.text = widget.projekt.name;
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
              for (var room in widget.projekt.rooms)
                ListTile(
                  title: Text(room.name),
                  tileColor: room == widget.projekt.rooms[widget.selectedIndex] ? Colors.grey[300] : null,
                  onTap: () {
                    widget.switchRoomCallBack(room);
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
                  renameRoomController.text = widget.projekt.rooms[widget.selectedIndex].name;

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
    PDFExport().generatePDF(widget.projekt.name);
  }

  void renameProject() {
    String newName = renameProjectController.text.trim();
    setState(() {
      widget.projekt.name = newName;
    });
    renameRoomController.clear();
    Navigator.pop(context);
  }

  void renameRoom() {
    String newName = renameRoomController.text.trim();
    if (newName.isNotEmpty) {
      setState(() {
        widget.projekt.rooms[widget.selectedIndex].name = newName;
      });
      renameRoomController.clear();
      Navigator.pop(context);
    }
  }

  void addNewRoom() {
    setState(() {
      String newRoomName = newRoomController.text.trim();
      if (newRoomName.isNotEmpty) {
        widget.projekt.rooms.add(Room(
          name: newRoomName,
        ));
        widget.switchRoomCallBack(widget.projekt.rooms.last);
        newRoomController.clear();
        Navigator.pop(context);
      }
    });
  }
}
