import 'dart:io';
import 'package:aufmass_app/PlanPage/planpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:aufmass_app/PlanPage/Room_Parts/room.dart';
import 'package:flutter_to_pdf/flutter_to_pdf.dart';

class PDFExport {
  // Singleton instance
  static final PDFExport _instance = PDFExport._internal();

  factory PDFExport() {
    return _instance;
  }

  PDFExport._internal();

  // Test Variablen
  List<TempRoom> rooms = [TempRoom(name: "Wohnzimmer", size: 20), TempRoom(name: "Küche", size: 10), TempRoom(name: "Bad", size: 5)];

  Future<void> generatePDF(String projectName, PlanPageContent planPage, ExportDelegate exportDelegate) async {
    final pdf = pw.Document();

    final ByteData image = await rootBundle.load('assets/eberl_logo.png');
    Uint8List imageData = (image).buffer.asUint8List();

    //Header
    pw.Widget header = pw.Header(
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(projectName),
            ],
          ),
          pw.Container(width: 50.0, height: 50.0, child: pw.Image(pw.MemoryImage(imageData))),
        ],
      ),
    );

    // Deckblatt
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(projectName),
        ),
      ),
    );

    // paint room
    /*pdf.addPage(
      pw.Page(
        build: (pw.Context context) => Test2(planPage: planPage //Test ist StatelessWidget; Probieren: Statt Test drawing_zone einfügen; problem, kein zugriff auf drawingzone
        ),
      ),
    );*/

    /*final ExportDelegate exportDelegate=ExportDelegate();
    dynamic test =ExportFrame(
      frameId: 'someFrameId',
      exportDelegate: exportDelegate,
      child: planPage.getCurrentRoom().drawRoomPart(),
    );*/
    // export the frame to a PDF Widget

  final ExportOptions overrideOptions = ExportOptions(
  pageFormatOptions: PageFormatOptions.a4(clip: true),
);

    final pdf2 = await exportDelegate.exportToPdfDocument('main', overrideOptions: overrideOptions);
    final file1 = File('example1.pdf');
    await file1.writeAsBytes(await pdf2.save());

    final widget = await exportDelegate.exportToPdfWidget('main'); //is somehow empty
    final page = await exportDelegate.exportToPdfPage('main');
    pdf.addPage(
      page
    );
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: widget,
        ),
      ),
    );

    
    //Auflistung von Räumen
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) => [
          header,
          pw.Text('Räume', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (pw.Context context, int index) {
              var room = rooms[index];
              return pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(room.name),
              );
            },
          ),
        ],
      ),
    );

    // Seite pro Raum
    for (var room in rooms) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(10),
          build: (pw.Context context) => [
            header,
            pw.SizedBox(height: 20),
            pw.Text('Room Name: ${room.name}'),
            pw.SizedBox(height: 10),
            pw.Text('Room Size: ${room.size}'),
          ],
        ),
      );
    }
    final file = File('example.pdf');
    await file.writeAsBytes(await pdf.save());
    print('PDF saved to ${file.path}');
  }

}


//testklasse
class TempRoom {
  String name;
  int size;

  TempRoom({
    required this.name,
    required this.size,
  });
}

class Test2 extends pw.StatelessWidget{

final PlanPageContent planPage;

  Test2({
    required this.planPage,
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.Stack(
            children:[
                //planPage.getCurrentRoom().drawRoomPart(),
              ]
          );
  }
}
class Test{

final PlanPageContent planPage;

  Test({
    required this.planPage,
  });

  @override
  Widget build(pw.Context context) {
    return Stack(
            children:[
                planPage.getCurrentRoom().drawRoomPart(),
              ]
          );
  }
}