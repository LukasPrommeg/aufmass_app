import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFExport {
  static Future<void> generatePDF() async {
    final pdf = pw.Document();

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('Test!'),
        ),
      ),
    );

    // Save the PDF to a file
    final file = File('example.pdf');
    await file.writeAsBytes(await pdf.save());
    print('PDF saved to ${file.path}');
  }
}