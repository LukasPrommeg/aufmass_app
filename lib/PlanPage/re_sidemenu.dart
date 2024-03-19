import 'package:aufmass_app/PlanPage/2D_Objects/einkerbung.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/flaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/grundflaeche.dart';
import 'package:aufmass_app/PlanPage/2D_Objects/linie.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitcontroller.dart';
import 'package:aufmass_app/PlanPage/Einheiten/einheitselector.dart';
import 'package:aufmass_app/PlanPage/Misc/alertinfo.dart';
import 'package:aufmass_app/PlanPage/Misc/overlap.dart';
import 'package:aufmass_app/PlanPage/Room_Parts/room_wall.dart';
import 'package:aufmass_app/PlanPage/SidemenuInputs/inputhandler.dart';
import 'package:aufmass_app/Werkstoffe/drawed_werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff_controller.dart';
import 'package:flutter/material.dart';

typedef RepaintCallback = void Function();
typedef SwitchToWallViewCallback = void Function(RoomWall roomWall);
typedef DeleteWallCallback=void Function(RoomWall roomWall);

class RightPlanpageSidemenu extends StatefulWidget {
  final dynamic clickedThing;
  final bool isWallView;
  final List<String> generatedWalls;
  final InputHandler inputHandler;
  final RepaintCallback onRepaintNeeded;
  final SwitchToWallViewCallback onWallViewGenerated;
  final DeleteWallCallback onWallDelete;

  RightPlanpageSidemenu({
    super.key,
    required this.clickedThing,
    required this.isWallView,
    required this.generatedWalls,
    required this.inputHandler,
    required this.onRepaintNeeded,
    required this.onWallViewGenerated,
    required this.onWallDelete,
  });

  @override
  State<RightPlanpageSidemenu> createState() => _RightPlanpageSidemenuState();

  final ValueNotifier<int> _unsubscribeTrigger = ValueNotifier<int>(0);
  void unsubscribeInputHandler() {
    _unsubscribeTrigger.value++;
  }
}

class _RightPlanpageSidemenuState extends State<RightPlanpageSidemenu> {
  final EinheitSelector _einheitSelector = EinheitSelector(
    setGlobal: true,
  );
  dynamic clickedThing;
  late Widget content;

  @override
  void initState() {
    super.initState();

    clickedThing = widget.clickedThing;

    initContent();

    widget.inputHandler.needsRepaintEvent.subscribe((args) => repaintHandler());

    widget._unsubscribeTrigger.addListener(() => unsubscribeInputHandler());
  }

  bool unsubscribed = false;

  void unsubscribeInputHandler() {
    widget.inputHandler.needsRepaintEvent.unsubscribeAll();
    unsubscribed = true;
  }

  @override
  void dispose() {
    if (!unsubscribed) {
      unsubscribeInputHandler();
    }
    super.dispose();
  }

  void repaintHandler() {
    setState(() {
      initContent();
    });
  }

   Map<Type, String> typeDisplayNames = {
    DrawedWerkstoff: 'Werkstoff',
    Grundflaeche: 'Fläche',
  };

  void initContent() {
    if (widget.inputHandler.currentlyHandling != CurrentlyHandling.nothing) {
      content = Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            widget.inputHandler.display(),
          ],
        ),
      );
    } else {
      content = Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                clickedThing==null
                ? "Nichts ausgewählt"
                : typeDisplayNames[clickedThing.runtimeType] ?? clickedThing.runtimeType.toString(),
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
                if (clickedThing is Flaeche && clickedThing is! Einkerbung) flaechenSideMenu(clickedThing),
                if (clickedThing is Linie && !widget.isWallView) wallSideMenu(clickedThing),
                if (clickedThing is DrawedWerkstoff) drawedWerkstoffSideMenu(clickedThing),
                if (clickedThing is Grundflaeche) grundflaecheSideMenu(clickedThing),
                if (clickedThing is Einkerbung) einkerbungSideMenu(clickedThing),
                if (clickedThing is Linie && widget.isWallView) linienSideMenu(clickedThing),
              ],
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    initContent();
    // Sidemenü rechts
    return Container(
      width: widget.inputHandler.currentlyHandling == CurrentlyHandling.nothing ? 200 : 325,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: const Border(
          left: BorderSide(
            color: Colors.deepPurple,
            width: 5,
          ),
        ),
      ),
      child: content,
    );
  }

  Widget flaechenSideMenu(Flaeche flaeche) {
    return Text("Fläche: ${EinheitController().convertToSelectedSquared(flaeche.area).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}²"); //have to reload for it to work
  }
  

  Widget wallSideMenu(Linie wall) {
    TextEditingController wallHeightController = TextEditingController();
    TextEditingController wallNameController = TextEditingController();
    bool autoDrawWall = true;

    return Column(
      children: [
        Text('Länge: ${EinheitController().convertToSelected(clickedThing.length).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}'),
        const Divider(),
        if (!widget.generatedWalls.contains(wall.uuid))
          Padding(
            padding:  const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              children: [
                TextField(
                  controller: wallNameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Name der Wand',
                  ),
                ),
                TextField(
                    controller: wallHeightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Wandhöhe',
                    ),
                ),
                //const Text("Wand automatisch zeichnen?"), //Wand kann direkt mit länge * eingestellter höhe gezeichnet werden
                /*Checkbox(
                  value: autoDrawWall,
                  onChanged: (bool? value) {
                    setState(() {
                      autoDrawWall = value!;
                    });
                  },
                ),*/
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    try {
                      if (autoDrawWall) {
                        double height = double.parse(wallHeightController.text);
                        height = _einheitSelector.convertToMM(height);
                        widget.onWallViewGenerated(RoomWall(
                          baseLine: wall,
                          height: height,
                          name: wallNameController.text=="" ? "Wand" : wallNameController.text,
                        ));
                      }
                    } 
                    catch (e) {
                      AlertInfo().newAlert("ERROR: Eingegebene Wandhöhe ist keine Zahl");
                    }
                  },
                  child: const Text('Wand Generieren'),
                ),
              ],
            ),
          )
        else
        Padding(
          padding: const EdgeInsets.only(right: 15, left: 15),
          child:
          Column(
            children: [
              const SizedBox(height: 10),
              ElevatedButton(
              onPressed: () {
                widget.onWallViewGenerated(RoomWall(
                  baseLine: wall,
                  height: 0,
                  name: "",
                ));
              },
              child: const Text('Wand Anzeigen'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                widget.onWallDelete(RoomWall(
                  baseLine: wall,
                  height: 0,
                  name: "",
                ));
              },
              child: const Text('Wand Löschen'),
            ),
          ],)
        ),
      ],
    );
  }

  Widget drawedWerkstoffSideMenu(DrawedWerkstoff werkstoff) {
    return Column(
      children: [
        Text(werkstoff.werkstoff.name),
        Text(werkstoff.amountStr),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Beschriftung"),
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
            const Text("Längen"),
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
        DropdownButton<Werkstoff>(
          value: clickedThing?.werkstoff ?? WerkstoffController().werkstoffe.first,
          onChanged: (Werkstoff? newValue) {
            setState(() {
              if (newValue != null) {
                werkstoff.werkstoff = newValue;
              }
            });
          },
          items: WerkstoffController().werkstoffe
          .where((werkstoff) => werkstoff.typ==clickedThing?.werkstoff?.typ)
          .map<DropdownMenuItem<Werkstoff>>((Werkstoff werkstoff2) {
            return DropdownMenuItem<Werkstoff>(
              value: werkstoff2,
              child: Text(werkstoff2.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget grundflaecheSideMenu(Grundflaeche grundFlaeche) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ExpansionTile(
          title: const Text("Einkerbungen"),
          shape: const Border(),
          children: [
            for (Einkerbung einkerbung in grundFlaeche.einkerbungen)
              ListTile(
                title: Text(einkerbung.name),
                onTap: () {
                  setState(() {
                    clickedThing = einkerbung;
                    initContent();
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
        Text(einkerbung.name),
        if(einkerbung.tiefe!= double.infinity)
        Text("Tiefe: ${EinheitController().convertToSelected((einkerbung).tiefe).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}"),
        Text("Fläche: ${EinheitController().convertToSelectedSquared((einkerbung).area).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}²"),
        const Divider(),
        ExpansionTile(
          title: const Text("Werkstoffe"),
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
                leading: const Icon(Icons.edit_square),
              ),
          ],
        ),
        const Divider(),
      ],
    );
  }
  Widget linienSideMenu(Linie linie) {
    return Text('Länge: ${EinheitController().convertToSelected(clickedThing.length).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}');
  }
}
