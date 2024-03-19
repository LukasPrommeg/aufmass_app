import 'dart:io';
import 'package:aufmass_app/PlanPage/Einheiten/einheitcontroller.dart';
import 'package:aufmass_app/PlanPage/Misc/loadingblur.dart';
import 'package:aufmass_app/PlanPage/Room_Parts/room_part.dart';
import 'package:aufmass_app/PlanPage/Room_Parts/room.dart';
import 'package:aufmass_app/PlanPage/Room_Parts/room_wall.dart';
import 'package:aufmass_app/PlanPage/planpage.dart';
import 'package:aufmass_app/Werkstoffe/werkstoff.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:printing/printing.dart'; 

class PDFExport {
  // Singleton instance
  static final PDFExport _instance = PDFExport._internal();

  factory PDFExport() {
    return _instance;
  }

  PDFExport._internal();

  ScreenshotController screenshotController = ScreenshotController();

  Future<void> generatePDF(String projectName, PlanPageContent planPage,BuildContext context) async {
    LoadingBlur().enableBlur();
    
    var theme = pw.ThemeData.withFont(
      base: await PdfGoogleFonts.openSansRegular(),
      bold: await PdfGoogleFonts.openSansBold(),
      icons: await PdfGoogleFonts.materialIcons(),
    );

    final pdf = pw.Document(theme: theme);

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
              return pw.Column(
                children:[
                  pw.Text('\u2022 ${room.name}'),
                  pw.ListView.builder(
                    itemCount: room.walls.values.toList().length,
                    itemBuilder: (pw.Context context, int index){
                      var roomWall=room.walls.values.toList()[index];
                      return pw.Column(
                        children:[
                          pw.Text('\u2022 ${roomWall.name}'), //\u25E6
                        ]
                      );
                    }
                  )
                ],
              );
            },
          ),
        ],
      ),
    );

    // Seite pro Raum
    for(var room in planPage.getProject().rooms){
      List<SizeInfo>sizes=calcSizes([room],false);

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
              pw.Text(room.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Container(child: pw.Image(pw.MemoryImage(capturedImage))),
              buildSizeInfo(sizes),
            ],
          ),
        );
      });

      //Seite pro roomWall
      for(var roomWall in room.walls.values.toList()){
        List<SizeInfo> sizes=roomWall.getSizes();
        sizes=calcSizes([roomWall],false);

        await screenshotController
        .captureFromWidget(roomWall.drawRoomPart())
        .then((capturedImage) {
          pdf.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(10),
              header: (context)=>buildHeader(projectName, imageData),
              footer: (context)=>buildFooter(context, projectName),
              build: (pw.Context context) => [
                pw.SizedBox(height: 20),
                pw.Text(room.name),
                pw.SizedBox(height: 5),
                pw.Text(roomWall.name,style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Container(child: pw.Image(pw.MemoryImage(capturedImage))),
                buildSizeInfo(sizes),
              ],
            ),
          );
        });
      }
    }
    
    //Seite mit allen Werkstoffen
    List<SizeInfo> sizes=calcSizes(planPage.getProject().rooms, true);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(10),
        header: (context)=>buildHeader(projectName, imageData),
        footer: (context)=>buildFooter(context, projectName),
        build: (pw.Context context) => [
          buildSizeInfo(sizes),
        ],
      ),
    );


    final file = File('example.pdf');
    await file.writeAsBytes(await pdf.save());
    print('PDF saved to ${file.path}');

    LoadingBlur().disableBlur();
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
          pw.Container(width: 50.0, height: 50.0, padding: const pw.EdgeInsets.symmetric(vertical: 5,horizontal: 0), child: pw.Image(pw.MemoryImage(imageData))),
        ],
      ),
    );
  }
  pw.Widget buildSizeInfo(List<SizeInfo> sizes){
    return pw.Container(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children:[
          pw.Text('Fläche ${EinheitController().convertToSelectedSquared((sizes.firstWhere((element) => element.name=="Room")).amount).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}²', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if(sizes.indexWhere((sizeInfo) => sizeInfo.name == "Wall")!=-1)
            pw.Text('Wände ${EinheitController().convertToSelectedSquared((sizes.firstWhere((element) => element.name=="Wall")).amount).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}²', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Verwendete Werkstoffe:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.ListView.builder(
            itemCount: sizes.length,
            itemBuilder: (pw.Context context, int index) {
              var size = sizes[index];
              if(size.name!="Wall"&&size.name!="Room"){
                return pw.Row(
                children:[
                  if(size.werkstoffTyp==WerkstoffTyp.flaeche)
                    pw.Column(
                      children: [
                        pw.Text('\u2022 ${size.name}: ${EinheitController().convertToSelectedSquared(size.amount).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}²')
                      ])
                    else if(size.werkstoffTyp==WerkstoffTyp.linie)
                      pw.Column(
                        children: [
                          pw.Text('\u2022 ${size.name}: ${EinheitController().convertToSelected(size.amount).toStringAsFixed(2)} ${EinheitController().selectedEinheit.name}'),
                      ])
                  ],
                );
              }else{
                return pw.Row(children: []);
              }
            },
          ),        
        ],
      )
    );
  }
  List<SizeInfo> calcSizes(List<RoomPart>rooms, bool finalcalc) {
    List<SizeInfo> sizes=[];
    for(var room in rooms){
      for (var sizeInfo in room.getSizes()){
        if(sizes.indexWhere((sizeInfo2) => sizeInfo2.name == sizeInfo.name)!=-1){
          sizes[sizes.indexWhere((sizeInfo2) => sizeInfo2.name == sizeInfo.name)].amount+=sizeInfo.amount;
        }else{
          sizes.add(sizeInfo);
        }
      }

      if(room.runtimeType!=RoomWall){
        for(var roomWall in (room as Room).walls.values.toList()){
          for (var sizeInfo in roomWall.getSizes()){
            if(sizeInfo.name=="Room"){
              sizeInfo.name="Wall";
            }
            if(sizeInfo.name=="Wall"||finalcalc){
                if(sizes.indexWhere((sizeInfo2) => sizeInfo2.name == sizeInfo.name)!=-1){
                  sizes[sizes.indexWhere((sizeInfo2) => sizeInfo2.name == sizeInfo.name)].amount+=sizeInfo.amount;
                }else{
                  sizes.add(sizeInfo);
                }
            }
          }
        }
      }
    }

    return sizes;
  }
}