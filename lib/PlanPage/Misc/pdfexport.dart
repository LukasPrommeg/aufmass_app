import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFExport {
  // Singleton instance
  static final PDFExport _instance = PDFExport._internal();

  factory PDFExport() {
    return _instance;
  }

  PDFExport._internal();

  // Test Variablen
  List<TempRoom> rooms = [TempRoom(name: "Wohnzimmer", size: 20), TempRoom(name: "Küche", size: 10), TempRoom(name: "Bad", size: 5)];

  Future<void> generatePDF(String projectName) async {
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
