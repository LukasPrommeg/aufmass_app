import 'package:aufmass_app/PlanPage/2D_Objects/einkerbung.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/flaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/grundflaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/wall.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitcontroller.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitselector.dart';
import 'package:aufmass_app/PlanPage/Misc/alertinfo.dart';
import 'package:aufmass_app/PlanPage/Misc/overlap.dart';
import 'package:aufmass_app/PlanPage/Paint/paintcontroller.dart';
import 'package:aufmass_app/PlanPage/Room_Parts/room_wall.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff_controller.dart';
import 'package:flutter/material.dart';

typedef RepaintCallback = void Function();
typedef SwitchToWallViewCallback = void Function(RoomWall roomWall);

class RightPlanpageSidemenu extends StatefulWidget {
  final dynamic clickedThing;
  final bool isWallView;
  final List<String> generatedWalls;
  final RepaintCallback onRepaintNeeded;
  final SwitchToWallViewCallback onWallViewGenerated;

  RightPlanpageSidemenu({
    super.key,
    required this.clickedThing,
    required this.isWallView,
    required this.generatedWalls,
    required this.onRepaintNeeded,
    required this.onWallViewGenerated,
  }) {
    print("ASD");
  }

  @override
  State<RightPlanpageSidemenu> createState() => _RightPlanpageSidemenuState();
}

class _RightPlanpageSidemenuState extends State<RightPlanpageSidemenu> {
  final EinheitSelector _einheitSelector = EinheitSelector(
    setGlobal: true,
  );
  dynamic clickedThing;

  @override
  void initState() {
    super.initState();

    clickedThing = widget.clickedThing;

    print("I FICK DEI MAM" + clickedThing.runtimeType.toString());
  }

  @override
  Widget build(BuildContext context) {
    // Sidemenü rechts
    return Container(
      width: 250,
      color: Colors.grey[200],
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                clickedThing.runtimeType.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              _einheitSelector,
              const Divider(),
            ],
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                if (clickedThing is Flaeche) flaechenSideMenu(clickedThing),
                if (clickedThing is Wall && !widget.isWallView) wallSideMenu(clickedThing),
                if (clickedThing is DrawedWerkstoff) drawedWerkstoffSideMenu(clickedThing),
                if (clickedThing is Grundflaeche) grundflaecheSideMeun(clickedThing),
                if (clickedThing is Einkerbung) einkerbungSideMenu(clickedThing),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget flaechenSideMenu(Flaeche flaeche) {
    return Text("Fläche: ${EinheitController().convertToSelectedSquared(flaeche.area).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}"); //have to reload for it to work
  }

  Widget wallSideMenu(Wall wall) {
    TextEditingController wallHeightController = TextEditingController();
    bool autoDrawWall = true;

    return Column(
      children: [
        Text(clickedThing.length.toString()),
        const Divider(),
        if (!widget.generatedWalls.contains(wall.uuid))
          Column(
            children: [
              TextField(
                controller: wallHeightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Wandhöhe',
                ),
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
            ],
          ),
        ElevatedButton(
          onPressed: () {
            if (widget.generatedWalls.contains(wall.uuid)) {
              widget.onWallViewGenerated(RoomWall(
                wall: wall,
                height: 0,
                name: "",
                paintController: PaintController(),
              ));
            } else {
              try {
                if (autoDrawWall) {
                  double height = double.parse(wallHeightController.text);
                  height = _einheitSelector.convertToMM(height);
                  widget.onWallViewGenerated(RoomWall(
                    wall: wall,
                    height: height,
                    name: "Wand",
                    paintController: PaintController(),
                  ));
                }
              } catch (e) {
                //TODO: ERROR
                AlertInfo().newAlert("ALARM");
              }
            }
          },
          child: const Text('Wand anzeigen'),
        ),
      ],
    );
  }

  Widget drawedWerkstoffSideMenu(DrawedWerkstoff werkstoff) {
    return Column(
      children: [
        Text(
          "Selected Werkstoff: ${werkstoff.werkstoff.name}",
          style: const TextStyle(fontSize: 18),
        ),
        const Divider(),
        Text(werkstoff.amountStr),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Beschriftung"),
            Switch(
              value: werkstoff.hasBeschriftung,
              onChanged: (value) {
                widget.onRepaintNeeded();
                setState(() {
                  werkstoff.hasBeschriftung = value;
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Längen"),
            Switch(
              value: werkstoff.hasLaengen,
              onChanged: (value) {
                widget.onRepaintNeeded();
                setState(() {
                  werkstoff.hasLaengen = value;
                });
              },
            ),
          ],
        ),
        //dropdownbutton with different werkstoffe; unklar: nur Werkstoffe vom selben Typ (wenn Fläche nur Flächen etc)
        DropdownButton<Werkstoff>(
          value: WerkstoffController()
              .werkstoffe
              .first, //cant be: cant have value: clickedThing?.werkstoff ?? WerkstoffController().werkstoffe.first, because clickedThing.werkstoff is not in the list of werkstoffe
          onChanged: (Werkstoff? newValue) {
            setState(() {
              if (newValue != null) {
                werkstoff.werkstoff = newValue;
              }
            });
          },
          items: WerkstoffController().werkstoffe.map<DropdownMenuItem<Werkstoff>>((Werkstoff werkstoff2) {
            return DropdownMenuItem<Werkstoff>(
              value: werkstoff2,
              child: Text(werkstoff2.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget grundflaecheSideMeun(Grundflaeche grundFlaeche) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ExpansionTile(
          title: Text("Einkerbungen"),
          shape: const Border(),
          children: [
            for (Einkerbung einkerbung in grundFlaeche.einkerbungen)
              ListTile(
                title: Text(einkerbung.name),
                onTap: () {
                  setState(() {
                    clickedThing = einkerbung;
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget einkerbungSideMenu(Einkerbung einkerbung) {
    return Column(
      children: [
        Text("Tiefe: ${EinheitController().convertToSelected((einkerbung).tiefe).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}"),
        Text("Fläche: ${EinheitController().convertToSelectedSquared((einkerbung).area).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}²"),
        const Divider(),
        ExpansionTile(
          title: Text("Werkstoffe"),
          shape: const Border(),
          children: [
            for (Overlap overlap in einkerbung.overlaps)
              ListTile(
                enableFeedback: false,
                iconColor: overlap.werkstoff.werkstoff.color,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(overlap.werkstoff.werkstoff.name),
                    Switch(
                      value: overlap.editMode,
                      onChanged: (value) {
                        widget.onRepaintNeeded();
                        setState(() {
                          overlap.editMode = value;
                        });
                      },
                    ),
                  ],
                ),
                onTap: () {
                  //clickedThing = einkerbung;
                },
                leading: Icon(Icons.edit_square),
              ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
