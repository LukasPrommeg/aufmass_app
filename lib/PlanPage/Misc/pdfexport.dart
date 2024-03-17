import 'dart:io';
import 'package:aufmass_app/PlanPage/planpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:aufmass_app/PlanPage/Room_Parts/room.dart';
import 'package:screenshot/screenshot.dart';

class PDFExport {
  // Singleton instance
  static final PDFExport _instance = PDFExport._internal();

  factory PDFExport() {
    return _instance;
  }

  PDFExport._internal();

  ScreenshotController screenshotController = ScreenshotController();

  Future<void> generatePDF(String projectName, PlanPageContent planPage,BuildContext context) async {
    final pdf = pw.Document();

    final ByteData image = await rootBundle.load('assets/eberl_logo.png');
    Uint8List imageData = (image).buffer.asUint8List();

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

  /*final ExportOptions overrideOptions = ExportOptions(
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
    );*/

    //Auflistung von Räumen
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(10),
        header: (context)=>buildHeader(projectName, imageData),
        footer: (context)=>buildFooter(context, projectName),
        build: (pw.Context context) => [
          pw.Text('Räume', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.ListView.builder(
            itemCount: planPage.getProject().rooms.length,
            itemBuilder: (pw.Context context, int index) {
              var room = planPage.getProject().rooms[index];
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
    for(var room in planPage.getProject().rooms){
      await screenshotController
      .captureFromWidget(room.drawRoomPart())
      .then((capturedImage) {
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(10),
            header: (context)=>buildHeader(projectName, imageData),
            footer: (context)=>buildFooter(context, projectName),
            build: (pw.Context context) => [
              pw.SizedBox(height: 20),
              pw.Text('Room Name: ${room.name}'),
              pw.SizedBox(height: 10),
              pw.Container(child: pw.Image(pw.MemoryImage(capturedImage))),
            ],
          ),
        );
      });
    }

    final file = File('example.pdf');
    await file.writeAsBytes(await pdf.save());
    print('PDF saved to ${file.path}');

    //TODO: eventuell ladeanimation während export
  }

  pw.Widget buildFooter(pw.Context context,String projectName) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Column(
        children: [
          pw.Divider(), // Add a divider for separation
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Page ${context.pageNumber}/${context.pagesCount}'),
              pw.Text(projectName),
            ],
          ),
        ],
      ),
    );
  }
  pw.Widget buildHeader(String projectName, Uint8List imageData) {
    return pw.Header(
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
  }

}