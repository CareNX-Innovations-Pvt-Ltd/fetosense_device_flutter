// ignore_for_file: non_constant_identifier_names
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/intrepretations2.dart';
import 'package:fetosense_device_flutter/data/models/marker_indices.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'dart:ui' as ui;
// import 'dart:io' as io;
import 'package:intl/intl.dart';

import '../../data/models/test_model.dart';

const directoryName = 'fetosense';

/// A class that generates a PDF view of the FHR (Fetal Heart Rate) graph.
class FhrPdfView2 {
  var WIDTH_PX = 2370;
  var HEIGHT_PX = 1700;

  double? pixelsPerOneMM;
  double? pixelsPerOneCM;

  double touched_down = 0;
  double touched_up = 0;
  late Paint graphOutlines;
  late Paint graphMovement;
  late Paint graphGridLines;
  Paint? graphBackGround;
  Paint? graphSafeZone;
  Paint? graphUnSafeZone;
  Paint? graphNoiseZone;
  Paint? graphAxisText;
  late Paint graphGridSubLines;
  late double yDivLength;
  late double yOrigin;
  late double axisFontSize;
  double? paddingLeft;
  double? paddingTop;
  double? paddingBottom;
  double? paddingRight;
  double? xOrigin;
  Paint? graphBpmLine;
  Paint? graphBpmLine2;
  Paint? graphBpmLine3;
  Paint? graphBpmLine4;
  double? xDivLength;
  late int xDiv;
  late int screenHeight;
  late int screenWidth;
  late double xAxisLength;
  late double yDiv;
  double? yAxisLength;
  late List<Canvas> canvas;
  late List<ui.PictureRecorder> recorder;
  late List<ui.Image> images;
  List<MemoryImage>? paths;
  late int timeScaleFactor;
  late int pointsPerPage;
  Paint? informationText;
  int XDIV = 20;
  int? pointsPerDiv;
  Test? mData;
  double? xTocoOrigin;
  late double yTocoOrigin;
  late double yTocoEnd;
  late double yTocoDiv;

  Interpretations2? _interpretations;

  int? scale;

  late bool comments;
  late bool auto;
  late bool highlight;

  int fhr2Offset =0;

  /// Constructor for the FhrPdfView2 class.
  /// Initializes the graph with the given length of the test.
  FhrPdfView2(int lengthOfTest) {
    initialize(lengthOfTest);
  }

  final prefs = GetIt.I<PreferenceHelper>();
  /// Generates the NST graph as a list of MemoryImages.
  Future<List<MemoryImage>?> getNSTGraph(
      Test? data, Interpretations2? interpretation) async {
    mData = data;
    if (mData!.lengthOfTest! > 3600) {
      auto = false;
      scale = 1;
      timeScaleFactor = 6;
    }

    _interpretations = interpretation;

    pointsPerPage = (10 * timeScaleFactor * XDIV);
    pointsPerDiv = timeScaleFactor * 10;
    int pages = (mData!.bpmEntries!.length / pointsPerPage).truncate();
    //pages += 1;
    if (mData!.bpmEntries!.length % pointsPerPage > 20) pages++;
    //pages++;
    //bitmaps = new Bitmap[pages];
    recorder = <ui.PictureRecorder>[];
    canvas = <Canvas>[];
    images = <ui.Image>[];
    paths = <MemoryImage>[];
    for (int i = 0; i < pages; i++) {
      recorder.add(ui.PictureRecorder());
      canvas.add(
        Canvas(
          recorder[i],
          Rect.fromPoints(
            const Offset(0.0, 0.0),
            Offset(
              WIDTH_PX.toDouble(),
              HEIGHT_PX.toDouble(),
            ),
          ),
        ),
      );
      canvas.last.scale(0.35, 0.35);
    }

    drawGraph(pages);
    //drawBpmLine(bpmList, pages);
    drawLine(mData!.bpmEntries, pages, graphBpmLine);
    drawLine(mData!.bpmEntries2, pages, graphBpmLine2, bpmOffset: fhr2Offset);
    drawLine(mData!.mhrEntries, pages, graphBpmLine3);
    //await drawLine(interpretation.baselineBpmList,pages,graphBpmLine);
    drawTocoLine(mData!.tocoEntries, pages, graphBpmLine);
    drawTocoLine(mData!.spo2Entries, pages, graphBpmLine4);
    drawMovements(mData!.movementEntries, pages);
    drawAutoMovements(mData!.autoFetalMovement, pages);
    //return bitmaps;
    debugPrint("highlight : $highlight $auto");

    if (_interpretations != null && auto && highlight) {
      debugPrint("highlight in : $highlight $auto");

      drawInterpretationAreas(
          _interpretations!.accelerationsList, pages, graphSafeZone);
      drawInterpretationAreas(
          _interpretations!.decelerationsList, pages, graphUnSafeZone);
      drawInterpretationAreas(
          _interpretations!.noiseList, pages, graphNoiseZone);
    }

    for (int i = 0; i < pages; i++) {
      final picture = recorder[i].endRecording();
      images.add(await picture.toImage(
          (WIDTH_PX * 0.35).toInt(), (HEIGHT_PX * 0.35).toInt()));

      paths!.add(await saveImage(i));
    }
    return paths;
  }

  /// Saves the generated image as a MemoryImage.
  Future<MemoryImage> saveImage(int i) async {
    var pngBytes =
        (await images[i].toByteData(format: ui.ImageByteFormat.png))!;
    /*// Use plugin [path_provider] to export image to storage
    io.Directory directory = await getTemporaryDirectory();
    String path = directory.path;
    debugPrint(path);
    await io.Directory('$path/$directoryName').create(recursive: true);
    var file = io.File('$path/$directoryName/temp$i.png');
    file.writeAsBytesSync(pngBytes.buffer.asInt8List());
    debugPrint(file.path);*/

    return MemoryImage(pngBytes.buffer.asUint8List());
  }

  void initialize(int lengthOfTest) {
    scale = prefs.getInt('scale') ?? 1;
    fhr2Offset = prefs.getInt('fhr2Offset') ?? 0;
    comments = prefs.getBool('comments') ?? false;
    auto = prefs.getBool('interpretations') ?? false;
    highlight = prefs.getBool('highlight') ?? false;
    debugPrint("highlight : $highlight $lengthOfTest");
    if (lengthOfTest < 180 || lengthOfTest > 3600) {
      auto = false;
      highlight = false;
      scale = 1;
    }

    timeScaleFactor = scale == 3 ? 2 : 6;
    //timeScaleFactor = 6;

    pixelsPerOneCM = 100;
    pixelsPerOneMM = 10;

    /*graphGridMainLines = new Paint()
      ..color = Colors.grey[400]
      ..strokeWidth = 1.5;*/
    graphGridLines = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.1;
    graphGridSubLines = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 0.6;
    graphOutlines = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.25;
    graphMovement = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;
    graphSafeZone = Paint()
      ..color = const Color.fromARGB(20, 100, 200, 0)
      ..strokeWidth = 1.0;
    graphUnSafeZone = Paint()
      ..color = const Color.fromARGB(40, 250, 30, 0)
      ..strokeWidth = 1.0;
    graphNoiseZone = Paint()
      ..color = const Color.fromARGB(100, 169, 169, 169)
      ..strokeWidth = 1.0;
    graphBpmLine = Paint()
      ..color = const Color.fromRGBO(38, 164, 36, 1.0)
      ..strokeWidth = pixelsPerOneMM! * .30;
    graphBpmLine2 = Paint()
      ..color = const Color.fromRGBO(12, 227, 16, 1.0)
      ..strokeWidth = pixelsPerOneMM! * .30;
    graphBpmLine3 = Paint()
      ..color = const Color.fromRGBO(197, 11, 95, 1.0)
      ..strokeWidth = pixelsPerOneMM! * .20;
    graphBpmLine4 = Paint()
      ..color = const Color.fromRGBO(150, 163, 243, 1.0)
      ..strokeWidth = pixelsPerOneMM! * .50;
    graphAxisText = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.75;

    informationText = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.75;

    axisFontSize = pixelsPerOneMM! * 5;

    paddingLeft = pixelsPerOneCM! * 2;
    paddingTop = pixelsPerOneCM;
    paddingBottom = pixelsPerOneCM;
    paddingRight = pixelsPerOneCM;
  }

  /// Initializes the graph with the given length of the test.
  void drawGraph(int pages) {
    screenHeight = HEIGHT_PX; //canvas.getHeight();//1440
    screenWidth = WIDTH_PX; //canvas.getWidth();//2560

    xTocoOrigin = paddingLeft;
    yTocoOrigin = screenHeight - paddingBottom! - pixelsPerOneCM!;

    xOrigin = paddingLeft;
    yOrigin = screenHeight - paddingBottom!;

    xDivLength = pixelsPerOneCM;
    // programatically decide
    //xDiv = (int) ((screenWidth - xOrigin - paddingRight) / pixelsPerOneCM);
    // static
    xDiv = 20;

    yAxisLength = yOrigin - paddingTop!;
    xAxisLength = xDiv *
        xDivLength!; //screenWidth - paddingLeft - pixelsPerOneCM - paddingRight;

    yOrigin = yTocoOrigin - xDivLength! * 6; // x= 2y

    yDivLength = xDivLength! / 2;
    yDiv = (yOrigin - paddingTop!) / pixelsPerOneCM! * 2;

    //reinitialize for toco
    //xOrigin = paddingLeft;
    yOrigin = yTocoOrigin - yDivLength * 12;

    yTocoEnd = yOrigin + xDivLength!;
    yTocoDiv = (yTocoOrigin - yTocoEnd) / pixelsPerOneCM! * 2;

    pointsPerPage = 10 * timeScaleFactor * xDiv;
    pointsPerDiv = timeScaleFactor * 10;

    for (int pageNumber = 0; pageNumber < pages; pageNumber++) {
      /*Bitmap.Config conf = Bitmap.Config.ARGB_8888; // see other conf types
      bitmaps[pageNumber] = Bitmap.createBitmap(screenWidth, screenHeight, conf); // this creates a MUTABLE bitmap
      canvas[pageNumber] = new Canvas(bitmaps[pageNumber]);*/
      //canvas[pageNumber].drawPaint(graphBackGround);

      //displayInformation(pageNumber);

      drawXAxis(pageNumber);

      drawYAxis(pageNumber);

      drawTocoXAxis(pageNumber);

      drawTocoYAxis(pageNumber);
    }
    //invalidate();
  }

  /// Draws the X-axis for the given page number.
  void drawXAxis(int pageNumber) {
    int interval = 10;
    int ymin = 50;
    int safeZoneMax = 160;

    //SafeZone
    Rect safeZoneRect = Rect.fromLTRB(
        xOrigin!,
        (yOrigin - yDivLength) - ((safeZoneMax - ymin) / interval) * yDivLength,
        xOrigin! + xAxisLength,
        yOrigin - yDivLength * 8); //50
    canvas[pageNumber].drawRect(safeZoneRect, graphSafeZone!);

    int numberOffset = XDIV * (pageNumber);

    canvas[pageNumber].drawLine(Offset(xOrigin! + xDivLength! / 2, paddingTop!),
        Offset(xOrigin! + xDivLength! / 2, yOrigin), graphGridSubLines);

    for (int i = 1; i <= xDiv; i++) {
      canvas[pageNumber].drawLine(
          Offset(xOrigin! + (xDivLength! * i), paddingTop!),
          Offset(xOrigin! + (xDivLength! * i), yOrigin),
          graphGridLines);

      //for (int j = 1; j < 2; j++) {
      canvas[pageNumber].drawLine(
          Offset(xOrigin! + (xDivLength! * i) + xDivLength! / 2, paddingTop!),
          Offset(xOrigin! + (xDivLength! * i) + xDivLength! / 2, yOrigin),
          graphGridSubLines);
      //}

      //if(i!=1)
      // old
      /*canvas[pageNumber].drawText(String.format("%2d", i + numberOffset),
                    xOrigin + (xDivLength * i) -
                            (graphAxisText.measureText("00") / 2),
                    yOrigin + axisFontSize * 3, graphAxisText);*/
    }
  }

  /// Draws the Y-axis for the given page number.
  void drawYAxis(int pageNumber) {
    //y-axis outlines
    canvas[pageNumber].drawLine(Offset(xOrigin!, yOrigin),
        Offset(xOrigin! + xAxisLength, yOrigin), graphOutlines);
    canvas[pageNumber].drawLine(Offset(xOrigin!, paddingTop!),
        Offset(xOrigin! + xAxisLength, paddingTop!), graphOutlines);

    int interval = 10;
    int ymin = 50;
    //int safeZoneMax = 160;

    //SafeZone
    /*Rect safeZoneRect = Rect.fromLTRB(xOrigin,
        (yOrigin - yDivLength) - ((safeZoneMax - ymin) / interval) * yDivLength,
        xOrigin + xAxisLength,
        yOrigin - yDivLength * 8);//50
    canvas[pageNumber].drawRect(safeZoneRect, graphSafeZone);*/

    for (int i = 1; i <= yDiv; i++) {
      if (i % 2 == 0) {
        canvas[pageNumber].drawLine(
            Offset(xOrigin!, yOrigin - (yDivLength * i)),
            Offset(xOrigin! + xAxisLength, yOrigin - (yDivLength * i)),
            graphGridLines);

        /*canvas[pageNumber].drawText("" + (ymin + (interval * (i - 1))), pixelsPerOneMM,
                        yOrigin - (yDivLength * i) + axisFontSize / 2, graphAxisText);*/
        canvas[pageNumber].drawParagraph(
            getParagraph("${(ymin + (interval * (i - 1)))}"),
            Offset(xOrigin! - pixelsPerOneCM!,
                yOrigin - (yDivLength * i + (pixelsPerOneMM! * 2))));

        canvas[pageNumber].drawLine(
            Offset(xOrigin!, yOrigin - (yDivLength * i) + yDivLength / 2),
            Offset(xOrigin! + xAxisLength,
                yOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      } else {
        canvas[pageNumber].drawLine(
            Offset(xOrigin!, yOrigin - (yDivLength * i)),
            Offset(xOrigin! + xAxisLength, yOrigin - (yDivLength * i)),
            graphGridSubLines);
        canvas[pageNumber].drawLine(
            Offset(xOrigin!, yOrigin - (yDivLength * i) + yDivLength / 2),
            Offset(xOrigin! + xAxisLength,
                yOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      }
    }
  }

  /// Draws the Toco X-axis for the given page number.
  void drawTocoXAxis(int pageNumber) {
    int numberOffset = XDIV * (pageNumber);
    for (int j = 1; j < 2; j++) {
      canvas[pageNumber].drawLine(
          Offset(xOrigin! + ((xDivLength! / 2) * j), yTocoEnd),
          Offset(xOrigin! + ((xDivLength! / 2) * j), yTocoOrigin),
          graphGridSubLines);
    }

    for (int i = 1; i <= xDiv; i++) {
      canvas[pageNumber].drawLine(
          Offset(xOrigin! + (xDivLength! * i), yTocoEnd),
          Offset(xOrigin! + (xDivLength! * i), yTocoOrigin),
          graphGridLines);

      //for (int j = 1; j < 2; j++) {
      canvas[pageNumber].drawLine(
          Offset(xOrigin! + (xDivLength! * i) + xDivLength! / 2, yTocoEnd),
          Offset(xOrigin! + (xDivLength! * i) + xDivLength! / 2, yTocoOrigin),
          graphGridSubLines);
      //}
      int offSet = ((numberOffset + i) / scale!).truncate();
      if ((numberOffset + i) % scale! == 0) {
        canvas[pageNumber].drawParagraph(
            getParagraph((offSet).toString()),
            Offset(xOrigin! + (xDivLength! * i) - (pixelsPerOneMM! * 7),
                yTocoOrigin + axisFontSize - (pixelsPerOneMM! * 4)));
      }
    }
  }

  /// Draws the Toco Y-axis for the given page number.
  void drawTocoYAxis(int pageNumber) {
    //y-axis outlines
    canvas[pageNumber].drawLine(Offset(xOrigin!, yTocoOrigin),
        Offset(xOrigin! + xAxisLength, yTocoOrigin), graphOutlines);
    canvas[pageNumber].drawLine(Offset(xOrigin!, yTocoEnd),
        Offset(xOrigin! + xAxisLength, yTocoEnd), graphOutlines);
    /*canvas[pageNumber].drawLine(
        Offset(paddingLeft! - pixelsPerOneCM!,
            yTocoOrigin + (pixelsPerOneCM! - pixelsPerOneMM!)),
        Offset(screenWidth - paddingRight!,
            yTocoOrigin + (pixelsPerOneCM! - pixelsPerOneMM!)),
        graphOutlines);*/

    /*canvas[pageNumber].drawLine(
        Offset(paddingLeft! - pixelsPerOneCM!, paddingTop!),
        Offset(paddingLeft! - pixelsPerOneCM!,
            yTocoOrigin + (pixelsPerOneCM! - pixelsPerOneMM!)),
        graphOutlines);*/

    int interval = 10;
    int ymin = 10;

    for (int i = 1; i <= yTocoDiv; i++) {
      if (i % 2 == 0) {
        canvas[pageNumber].drawLine(
            Offset(xOrigin!, yTocoOrigin - (yDivLength * i)),
            Offset(xOrigin! + xAxisLength, yTocoOrigin - (yDivLength * i)),
            graphGridLines);

        canvas[pageNumber].drawParagraph(
            getParagraph("${(ymin + (interval * (i - 1)))}"),
            Offset(xOrigin! - pixelsPerOneCM!,
                yTocoOrigin - (yDivLength * i + (pixelsPerOneMM! * 2))));

        canvas[pageNumber].drawLine(
            Offset(xOrigin!, yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            Offset(xOrigin! + xAxisLength,
                yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      } else {
        canvas[pageNumber].drawLine(
            Offset(xOrigin!, yTocoOrigin - (yDivLength * i)),
            Offset(xOrigin! + xAxisLength, yTocoOrigin - (yDivLength * i)),
            graphGridSubLines);
        canvas[pageNumber].drawLine(
            Offset(xOrigin!, yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            Offset(xOrigin! + xAxisLength,
                yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      }
    }
  }

  /// Displays information on the graph for the given page number.
  void displayInformation(int pageNumber) {
    int rows = 3;

    String date = DateFormat('dd MMM yyyy').format(mData!.createdOn!);
    String time = DateFormat('hh:mm a').format(mData!.createdOn!);

    //String.format("%s  %s %s", now.substring(11, 16), now.substring(8, 10),now.substring(4, 10), now.substring(now.lastIndexOf(" ")+3));

    double rowHeight = pixelsPerOneCM! * 0.7;
    double rowPos = rowHeight * 0.5;

    //mData.setOrganizationName("hospital i Morey MD FICOG and so on");
    if (mData!.organizationName != null &&
        mData!.organizationName!.length >= 30) {
      String s1 = mData!.organizationName!.substring(0, 30);
      s1 = mData!.organizationName!.substring(0, s1.lastIndexOf(" ") + 1);
      String s2 =
          mData!.organizationName!.replaceAll(s1, ""); //.replace(s1,"");
      canvas[pageNumber].drawParagraph(getParagraphInfo(s1), Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(
          getParagraphInfo(s2),
          Offset(
            0,
            rowPos - pixelsPerOneMM!,
          ));
      rowPos += rowHeight;
    } else {
      canvas[pageNumber]
          .drawParagraph(getParagraphInfo("Hospital :"), Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(
          getParagraphInfo(mData!.organizationName ?? ""),
          Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    }
    //mData.setDoctorName("Dr Bharati Morey MD FICOG and so on");
    if (mData!.doctorName != null && mData!.doctorName!.length >= 30) {
      String s1 = mData!.doctorName!.substring(0, 30);
      s1 = mData!.doctorName!.substring(0, s1.lastIndexOf(" ") + 1);
      String s2 = mData!.doctorName ?? "";

      canvas[pageNumber].drawParagraph(getParagraphInfo(s1), Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(
          getParagraphInfo(s2), Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    } else {
      canvas[pageNumber]
          .drawParagraph(getParagraphInfo("Doctor :"), Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(
          getParagraphInfo(mData!.doctorName ?? ""),
          Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    }

    //mData.setpatientId("sds");
    if (mData!.patientId != null && mData!.patientId!.length >= 30) {
      String s1 = mData!.patientId!.substring(0, 30);
      s1 = mData!.patientId!.substring(0, s1.lastIndexOf(" ") + 1);
      String s2 = mData!.patientId!.replaceAll(s1, "");

      canvas[pageNumber].drawParagraph(getParagraphInfo(s1), Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(
          getParagraphInfo(s2), Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    } else {
      canvas[pageNumber]
          .drawParagraph(getParagraphInfo("Patient Id :"), Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(getParagraphInfo(mData!.patientId ?? ""),
          Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    }

    //mData.setMotherName("Dr Bharati Morey MD FICOG and so on asdsa");
    if (mData!.motherName != null && mData!.motherName!.length >= 30) {
      String s1 = mData!.motherName!.substring(0, 30);
      s1 = mData!.motherName!.substring(0, s1.lastIndexOf(" ") + 1);
      String s2 = mData!.motherName!.replaceAll(s1, "");

      canvas[pageNumber].drawParagraph(getParagraphInfo(s1), Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(
          getParagraphInfo(s2), Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    } else {
      canvas[pageNumber]
          .drawParagraph(getParagraphInfo("Mother :"), Offset(0, rowPos));
      rowPos += rowHeight * 0.8;
      canvas[pageNumber].drawParagraph(
          getParagraphInfo(mData!.motherName ?? ""),
          Offset(0, rowPos - pixelsPerOneMM!));
      rowPos += rowHeight;
    }

    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            ("Duration :  ${(mData!.lengthOfTest! / 60).truncate()} min")),
        Offset(0, rowPos));
    rowPos += rowHeight;

    canvas[pageNumber]
        .drawParagraph(getParagraphInfo("Time : $time"), Offset(0, rowPos));
    rowPos += rowHeight;
    canvas[pageNumber]
        .drawParagraph(getParagraphInfo("Date : $date"), Offset(0, rowPos));
    rowPos += rowHeight;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo("Gest. Week : ${mData!.gAge}"), Offset(0, rowPos));
    rowPos += rowHeight;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            "Basal HR : ${auto ? _interpretations!.getBasalHeartRateStr() : ' _______'}"),
        Offset(0, rowPos));
    rowPos += rowHeight;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            "FM : ${mData!.movementEntries!.length ?? "--"} man/ ${mData!.autoFetalMovement!.length ?? "--"} auto "),
        Offset(0, rowPos));

    rowPos += rowHeight;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            "Accelerations : ${auto ? _interpretations!.getnAccelerationsStr() : ' _______'}"), //+mData.getWeight(),
        Offset(0, rowPos));
    rowPos += rowHeight;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            "Decelerations : ${auto ? _interpretations!.getnDecelerationsStr() : ' _______'}"),
        Offset(0, rowPos));
    rowPos += rowHeight;
    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            "STV : ${auto ? '${_interpretations!.getShortTermVariationBpmStr()} bpm / ${_interpretations!.getShortTermVariationMilliStr() ?? "--"} milli' : ' _______'}"),
        Offset(0, rowPos));
    rowPos += rowHeight;
    canvas[pageNumber].drawParagraph(
        getParagraphInfo(
            "LTV : ${auto ? '${_interpretations!.getLongTermVariationStr()} bpm' : ' _______'}"),
        Offset(0, rowPos));
    rowPos += rowHeight;

    canvas[pageNumber]
        .drawParagraph(getParagraphInfo("Conclusion :"), Offset(0, rowPos));
    rowPos += pixelsPerOneMM! * 3;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo("(Reactive, Non-Reactive, Inconclusive)",
            fontsize: 20),
        Offset(0, rowPos));

    rowPos = yTocoOrigin + rowHeight;
    rowPos -= rowHeight * 0.5;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo('X-Axis : ${timeScaleFactor * 10} SEC/DIV'),
        Offset(0, rowPos));
    rowPos += rowHeight * 0.6;

    canvas[pageNumber].drawParagraph(
        getParagraphInfo("Y-Axis : 20 BPM/DIV"), Offset(0, rowPos));
    rowPos += rowHeight * 1.5;
  }

  void drawLine(List<int>? bpmList, int pages, Paint? style,
      {int bpmOffset = 0}) {
    if (bpmList == null) {
      return;
    }

    for (int pageNumber = 0; pageNumber < pages; pageNumber++) {
      double startX, startY, stopX = 0, stopY = 0;
      int startData, stopData = 0;

      for (int i = (pageNumber * pointsPerPage), j = 0;
          i < bpmList.length && j < pointsPerPage;
          i++, j++) {
        startData = stopData;
        stopData = bpmList[i];

        startX = stopX;
        startY = stopY;

        stopX = getScreenX(i, pageNumber);
        stopY =
            getYValueFromBPM(bpmList[i] + bpmOffset); // getScreenY(stopData);

        if (i < 1) continue;
        if (startData == 0 ||
            stopData == 0 ||
            startData > 210 ||
            stopData > 210 ||
            (startData - stopData).abs() > 30) {
          continue;
        }

        // a. If the value is 0, it is not drawn
        // b. If the results of the two values before and after are different by more than 30, they are not connected.

        canvas[pageNumber]
            .drawLine(Offset(startX, startY), Offset(stopX, stopY), style!);
      }
    }
  }

  /// Returns the X-coordinate on the screen for the given index and start index.
  double getScreenX(int i, int startIndex) {
    double increment = (pixelsPerOneMM! / timeScaleFactor);
    double k = xOrigin! + increment * 4;
    k += increment * (i - (startIndex * pointsPerPage));
    return k;
  }

  /// Draws the Toco line on the graph for the given pages.
  void drawTocoLine(List<int>? tocoEntries, int pages, Paint? lineStyle) {
    if (mData!.tocoEntries == null) {
      return;
    }

    for (int pageNumber = 0; pageNumber < pages; pageNumber++) {
      double startX, startY, stopX = 0, stopY = 0;
      int startData, stopData = 0;

      for (int i = (pageNumber * pointsPerPage), j = 0;
          i < tocoEntries!.length && j < pointsPerPage;
          i++, j++) {
        startData = stopData;
        stopData = tocoEntries[i];

        startX = stopX;
        startY = stopY;

        stopX = getScreenX(i, pageNumber);
        stopY = getYValueFromToco(tocoEntries[i]); // getScreenY(stopData);

        if (i < 1) continue;
        if ((startData - stopData).abs() > 80) {
          continue;
        }

        if (startData == 0 ||
            stopData == 0 ||
            startData > 210 ||
            stopData > 210 ||
            (startData - stopData).abs() > 30) {
          continue;
        }

        // a. If the value is 0, it is not drawn
        // b. If the results of the two values before and after are different by more than 30, they are not connected.

        canvas[pageNumber]
            .drawLine(Offset(startX, startY), Offset(stopX, stopY), lineStyle!);
      }
    }
  }

  /// Draws the movements on the graph for the given pages.
  void drawMovements(List<int>? movementList, int pages) {
    for (int pageNumber = 0; pageNumber < pages; pageNumber++) {
      if (movementList == null || movementList.length == 0) return;

      double increment = (pixelsPerOneMM! / timeScaleFactor);
      for (int i = 0; i < movementList.length; i++) {
        int movement = movementList[i] - (pageNumber * pointsPerPage);
        if (movement > 0 && movement < pointsPerPage) {
          canvas[pageNumber].drawLine(
              Offset(xOrigin! + (increment * (movement)),
                  yOrigin + pixelsPerOneMM! * 2),
              Offset(xOrigin! + (increment * (movement)),
                  yOrigin + pixelsPerOneMM! * 2 + (pixelsPerOneMM! * 4)),
              graphMovement);
          canvas[pageNumber].drawLine(
              Offset(xOrigin! + (increment * (movement)),
                  yOrigin + pixelsPerOneMM! * 2),
              Offset(xOrigin! + (increment * (movement)) + pixelsPerOneMM!,
                  yOrigin + pixelsPerOneMM! * 2 + (pixelsPerOneMM! * 2)),
              graphMovement);
        }
      }
    }

    //Testing dummy movements
    /* for (int pageNumber = 0;pageNumber<pages;pageNumber++) {
            int move[] = {2, 12, 24,60, 120, 240, 300, 420, 600,690, 1220, 1240, 1300, 1420, 1600};
            for (int i = 0; i < move.length; i++) {

               if (move[i]-(pageNumber*pointsPerPage) > 0 && move[i]-(pageNumber*pointsPerPage) < pointsPerPage)
                    canvas[pageNumber].drawBitmap(movementBitmap,
                            xOrigin+(pixelsPerOneMM/timeScaleFactor*(move[i]-(pageNumber*pointsPerPage))-(movementBitmap.getWidth()/2)),
                            yOrigin+pixelsPerOneMM, null);


            }
        }*/
  }

  /// Draws the automatic movements on the graph for the given pages.
  void drawAutoMovements(List<int>? movementList, int pages) {
    for (int pageNumber = 0; pageNumber < pages; pageNumber++) {
      if (movementList == null || movementList.length == 0) return;

      double increment = (pixelsPerOneMM! / timeScaleFactor);
      for (int i = 0; i < movementList.length; i++) {
        int movement = movementList[i] - (pageNumber * pointsPerPage);
        if (movement > 0 && movement < pointsPerPage) {
          /*canvas[pageNumber].drawLine(
              new Offset(xOrigin + (increment * (movement)),
                  yOrigin + pixelsPerOneMM * 2),
              new Offset(xOrigin + (increment * (movement)),
                  yOrigin + pixelsPerOneMM * 2 + (pixelsPerOneMM * 4)),
              graphMovement);
          canvas[pageNumber].drawLine(
              new Offset(xOrigin + (increment * (movement)),
                  yOrigin + pixelsPerOneMM * 2),
              new Offset(xOrigin + (increment * (movement)) + pixelsPerOneMM,
                  yOrigin + pixelsPerOneMM * 2 + (pixelsPerOneMM * 2)),
              graphMovement);*/

          canvas[pageNumber].drawLine(
              Offset(xOrigin! + (increment * (movement)),
                  yOrigin - pixelsPerOneCM! + pixelsPerOneMM!),
              Offset(xOrigin! + (increment * (movement)),
                  yOrigin - pixelsPerOneMM! * 3),
              graphOutlines);
          canvas[pageNumber].drawLine(
              Offset(xOrigin! + (increment * (movement)),
                  yOrigin - pixelsPerOneCM! + pixelsPerOneMM!),
              Offset(
                  xOrigin! +
                      (increment * (movement)) +
                      pixelsPerOneMM! +
                      pixelsPerOneMM!,
                  yOrigin - pixelsPerOneMM! * 7),
              graphOutlines);
          canvas[pageNumber].drawLine(
              Offset(xOrigin! + (increment * (movement)),
                  yOrigin - pixelsPerOneCM! + pixelsPerOneMM! * 7),
              Offset(
                  xOrigin! +
                      (increment * (movement)) +
                      pixelsPerOneMM! +
                      pixelsPerOneMM!,
                  yOrigin - pixelsPerOneMM! * 5),
              graphOutlines);
        }
      }
    }

    //Testing dummy movements
    /* for (int pageNumber = 0;pageNumber<pages;pageNumber++) {
            int move[] = {2, 12, 24,60, 120, 240, 300, 420, 600,690, 1220, 1240, 1300, 1420, 1600};
            for (int i = 0; i < move.length; i++) {

               if (move[i]-(pageNumber*pointsPerPage) > 0 && move[i]-(pageNumber*pointsPerPage) < pointsPerPage)
                    canvas[pageNumber].drawBitmap(movementBitmap,
                            xOrigin+(pixelsPerOneMM/timeScaleFactor*(move[i]-(pageNumber*pointsPerPage))-(movementBitmap.getWidth()/2)),
                            yOrigin+pixelsPerOneMM, null);


            }
        }*/
  }

  /// Draws the interpretation areas on the graph for the given pages.
  void drawInterpretationAreas(
      List<MarkerIndices>? list, int pages, Paint? style) {
    for (int pageNumber = 0; pageNumber < pages; pageNumber++) {
      if (list == null || list.isEmpty) return;

      double? startX, stopX = 0;

      for (int i = 0; i < list.length; i++) {
        startX = getScreenX((list[i].getFrom() - 3), pageNumber);
        stopX = getScreenX(list[i].getTo() + 3, pageNumber);

        if (startX < xOrigin!) startX = xOrigin;
        if (stopX < xOrigin!) stopX = xOrigin;
        if (startX == stopX) continue;
        //Marker
        Rect zoneRect =
            Rect.fromLTRB(startX!, paddingTop!, stopX!, yTocoOrigin); //50
        canvas[pageNumber].drawRect(zoneRect, style!);
      }
    }
  }

  int scaleOrigin = 40;

  /// Returns the Y-coordinate on the screen for the given BPM value.
  double getYValueFromBPM(int bpm) {
    double adjustedBPM = (bpm - scaleOrigin).toDouble();
    adjustedBPM = adjustedBPM / 2; //scaled down version for mobile phone
    double y_value = yOrigin - (adjustedBPM * pixelsPerOneMM!);
    //Log.i("bpmvalue",bpm+" "+adjustedBPM+" "+y_value);
    return y_value;
  }

  /// Returns the Y-coordinate on the screen for the given Toco value.
  double getYValueFromToco(int bpm) {
    double adjustedBPM = bpm.toDouble();
    adjustedBPM = adjustedBPM / 2; //scaled down version for mobile phone
    double yValue = yTocoOrigin - (adjustedBPM * pixelsPerOneMM!);
    //Log.i("bpmvalue", bpm + " " + adjustedBPM + " " + y_value);
    return yValue;
  }

  /// Returns a paragraph with the given text for the graph.
  ui.Paragraph getParagraph(String text) {
    if (text.length == 1) text = "0$text";
    ui.ParagraphBuilder builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(fontSize: 30.0, textAlign: TextAlign.right))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(text);
    final ui.Paragraph paragraph = builder.build()
      ..layout(const ui.ParagraphConstraints(width: 80));
    return paragraph;
  }

  /// Returns a paragraph with the given text for the graph information.
  ui.Paragraph getParagraphInfo(String text, {double fontsize = 30}) {
    if (text.length == 1) text = "0$text";
    ui.ParagraphBuilder builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(fontSize: fontsize, textAlign: TextAlign.left))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(text);
    final ui.Paragraph paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: paddingLeft! * 9));
    return paragraph;
  }

  /// Returns a paragraph with the given text for the graph with specified width.
  ui.Paragraph getParagraphLong(String text, double width,
      {double fontsize = 30, TextAlign align = TextAlign.left}) {
    if (text.length == 1) text = "0$text";
    ui.ParagraphBuilder builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(fontSize: fontsize, textAlign: align))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(text);
    final ui.Paragraph paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: width));
    return paragraph;
  }
}
