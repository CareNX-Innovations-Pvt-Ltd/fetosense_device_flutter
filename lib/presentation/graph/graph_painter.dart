import 'dart:ui' as ui;

import 'package:fetosense_device_flutter/data/models/intrepretations2.dart';
import 'package:fetosense_device_flutter/data/models/markerIndices.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:flutter/material.dart';

class GraphPainter extends CustomPainter {
  /// Test data containing BPM, TOCO and movement measurements
  final Test? test;

  /// Top padding for graph area
  late double paddingTop;

  /// Bottom padding for graph area
  double? paddingBottom;

  /// Right padding for graph area
  late double paddingRight;

  /// Scale factor for time axis
  late int timeScaleFactor;

  /// Origin x-coordinate for TOCO graph
  double? xTocoOrigin;

  /// Origin y-coordinate for TOCO graph
  late double yTocoOrigin;

  /// Origin x-coordinate for graph
  late double xOrigin;

  /// Origin y-coordinate for graph
  late double yOrigin;

  /// Length of y-axis
  double? yAxisLength;

  /// Length of x-axis
  late double xAxisLength;

  /// Length of x-axis division
  double? xDivLength;

  /// Number of x-axis divisions
  late int xDiv;

  /// Length of y-axis division
  late double yDivLength;

  /// End y-coordinate for TOCO graph
  late double yTocoEnd;

  /// Length of TOCO y-axis division
  late double yTocoDiv;

  /// Points per division
  late int pointsPerDiv;

  /// Points per page
  late int pointsPerPage;

  /// Increment for x-axis
  late double mIncrement;

  /// Length of y-axis division
  late double yDiv;

  /// Paint objects for different graph elements
  late Paint graphGridMainLines; // Major grid lines

  late Paint graphGridSubLines; // Minor grid lines

  late Paint graphGridLines; // Regular grid lines

  late Paint graphOutlines; // Graph borders

  Paint? graphSafeZone; // Safe zone highlighting
  Paint? graphUnSafeZone; // Unsafe zone highlighting
  Paint? graphNoiseZone; // Noise area highlighting

  /// Grid density (lines per minute)
  int? gridPerMin = 3;

  /// Horizontal offset for graph scrolling
  int mOffset = 0;

  /// Touch mode flag
  bool mTouchMode = false;

  /// Paint objects for BPM lines
  Paint? graphBpmLine;
  Paint? graphBpmLine2;
  Paint? graphBaseLine;

  /// Origin for BPM scale
  int scaleOrigin = 40;

  /// Paint object for MHR line
  Paint? graphMHRLine;

  /// Starting x-coordinate of touch gesture
  double mTouchStart = 0;

  /// Initial start index for touch gesture
  int mTouchInitialStartIndex = 0;

  /// Graph interpretation results
  Interpretations2? interpretations;

  GraphPainter(this.test, this.mOffset, this.gridPerMin, this.interpretations);

  /// Screen height
  late double screenHeight;

  /// Screen width
  late double screenWidth;

  /// Pixels per centimeter
  double? pixelsPerOneCM;

  /// Pixels per millimeter
  double? pixelsPerOneMM;

  /// Left offset start
  double? leftOffsetStart;

  /// Top offset end
  double? topOffsetEnd;

  /// Drawing width
  double? drawingWidth;

  /// Drawing height
  double? drawingHeight;

  static const int NUMBER_OF_HORIZONTAL_LINES = 5;


  /// Main paint method that draws the entire graph
  @override
  void paint(Canvas canvas, Size size) {
    screenHeight = size.height;
    screenWidth = size.width;

    pixelsPerOneCM = screenHeight / 16;
    pixelsPerOneMM = pixelsPerOneCM! / 10;

    leftOffsetStart = size.width * 0.07;
    topOffsetEnd = size.height * 0.9;
    drawingWidth = size.width * 0.93;
    drawingHeight = topOffsetEnd;

    graphGridMainLines = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = pixelsPerOneMM! * 0.65;
    graphGridLines = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = pixelsPerOneMM! * 0.40;
    graphGridSubLines = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = pixelsPerOneMM! * 0.20;
    graphOutlines = Paint()
      ..color = Colors.black
      ..strokeWidth = pixelsPerOneMM! * .80;
    graphSafeZone = Paint()
      ..color = const Color.fromARGB(40, 100, 200, 0)
      ..strokeWidth = pixelsPerOneMM! * .40;
    graphUnSafeZone = Paint()
      ..color = const Color.fromARGB(40, 250, 30, 0)
      ..strokeWidth = pixelsPerOneMM! * .40;
    graphNoiseZone = Paint()
      ..color = const Color.fromARGB(100, 169, 169, 169)
      ..strokeWidth = pixelsPerOneMM! * .40;
    graphBpmLine = Paint()
      ..color = Colors.blue
      ..strokeWidth = pixelsPerOneMM! * .40;
    graphBpmLine2 = Paint()
      ..color = Colors.black54
      ..strokeWidth = pixelsPerOneMM! * .40;
    graphBaseLine = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = pixelsPerOneMM! * .50;

    Color mhrColor = const Color.fromRGBO(197, 11, 95, 1.0);//Color(0xFFEA62AB);
    graphMHRLine = Paint()
      ..color = mhrColor
      ..strokeWidth = pixelsPerOneMM! * .40;

    init(size);

    drawGraph(canvas);
  }


  /// Determines whether the painter should repaint
  @override
  bool shouldRepaint(GraphPainter oldDelegate) {
    if (oldDelegate.mOffset != mOffset) {
      return true;
    } else {
      return false;
    }
  }

  void init(Size size) {
    var paddingLeft = size.width * 0.07;

    paddingTop = pixelsPerOneCM! * 0.7;
    paddingBottom = pixelsPerOneMM;
    paddingRight = pixelsPerOneMM! * 2;

    timeScaleFactor = gridPerMin == 1 ? 6 : 2;

    xTocoOrigin = paddingLeft;
    yTocoOrigin = screenHeight - paddingBottom!;

    xOrigin = paddingLeft;
    yOrigin = screenHeight - paddingBottom!;

    yAxisLength = yOrigin - paddingTop;
    xAxisLength = screenWidth - paddingLeft - paddingRight;

    xDivLength = pixelsPerOneCM;
    xDiv = ((screenWidth - xOrigin - paddingRight) / pixelsPerOneCM!).truncate();

    yOrigin = yTocoOrigin - xDivLength! * 6; // x= 2y

    yDivLength = xDivLength! / 2;
    yDiv = (yOrigin - paddingTop) / pixelsPerOneCM! * 2;

    yOrigin = yTocoOrigin - yDivLength * 12;

    yTocoEnd = yOrigin + xDivLength!;
    yTocoDiv = (yTocoOrigin - yTocoEnd) / pixelsPerOneCM! * 2;

    pointsPerDiv = (timeScaleFactor * 10);
    pointsPerPage = (pointsPerDiv * xDiv + (pointsPerDiv / 2)).truncate();

    mIncrement = (pixelsPerOneMM! / timeScaleFactor);
    //nstTouchMove(offset);
    mOffset = trap(mOffset);
  }

  /// Draws the complete graph
  drawGraph(Canvas canvas) {
    drawXAxis(canvas);
    drawYAxis(canvas);

    drawTocoXAxis(canvas);
    drawTocoYAxis(canvas);

    // drawBPMLine(canvas, interpretations!.baselineBpmList, graphBaseLine);
    drawBPMLine(canvas, test!.bpmEntries, graphBpmLine);
    drawBPMLine(canvas, test!.bpmEntries2, graphBpmLine2);
    drawMHRLine(canvas, test!.mhrEntries, graphMHRLine);

    drawMovements(canvas);
    drawAutoMovements(canvas);
    drawTocoLine(canvas);

    // drawInterpretationAreas(
    //     canvas, interpretations!.getAccelerationsList(), graphSafeZone);
    // drawInterpretationAreas(
    //     canvas, interpretations!.getDecelerationsList(), graphUnSafeZone);
    // drawInterpretationAreas(
    //     canvas, interpretations!.getNoiseAreaList(), graphNoiseZone);

    // canvas.drawLine(
    //     new Offset(xOrigin + 20,
    //         yOrigin - pixelsPerOneCM ),
    //     new Offset(xOrigin + 20,
    //         yOrigin - pixelsPerOneMM * 3),
    //     graphOutlines);

  }

  /// Returns a [ui.Paragraph] object for the given text.
  ui.Paragraph getParagraph(String text) {
    if (text.length == 1) text = "0$text";
    ui.ParagraphBuilder builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(fontSize: 10.0, textAlign: TextAlign.right))
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(text);
    final ui.Paragraph paragraph = builder.build()
      ..layout(const ui.ParagraphConstraints(width: 20));
    return paragraph;
  }

  // bool printMin = true;

  /// Draws the main x-axis with grid lines and time labels
  void drawXAxis(Canvas canvas) {
    //SafeZone
    int interval = 10;
    int ymin = 50;
    int safeZoneMax = 160;
    Rect safeZoneRect = Rect.fromLTRB(
        xOrigin,
        (yOrigin - yDivLength) - ((safeZoneMax - ymin) / interval) * yDivLength,
        xOrigin + xAxisLength,
        yOrigin - yDivLength * 8); //50
    canvas.drawRect(safeZoneRect, graphSafeZone!);
    //safe zone end

    canvas.drawLine(Offset(xOrigin + xDivLength! / 2, paddingTop),
        Offset(xOrigin + xDivLength! / 2, yOrigin), graphGridSubLines);

    for (int i = 1; i <= xDiv; i++) {
      canvas.drawLine(Offset(xOrigin + (xDivLength! * i), paddingTop),
          Offset(xOrigin + (xDivLength! * i), yOrigin), graphGridLines);

      canvas.drawLine(
          Offset(
              xOrigin + (xDivLength! * i) + xDivLength! / 2, paddingTop),
          Offset(xOrigin + (xDivLength! * i) + xDivLength! / 2, yOrigin),
          graphGridSubLines);
      int offset = (mOffset / pointsPerDiv).truncate();
      if ((i + offset) % gridPerMin! == 0) {
        // if (gridPerMin == 1 && printMin) {
        //   canvas.drawParagraph(
        //       getParagraph(((i + (offset)) / gridPerMin).truncate().toString()),
        //       new Offset(xOrigin + (xDivLength * i) - pixelsPerOneMM * 5,
        //           pixelsPerOneCM * 0.2));
        // } else if (gridPerMin == 3) {
        canvas.drawParagraph(
            getParagraph(((i + (offset)) / gridPerMin!).truncate().toString()),
            Offset(xOrigin + (xDivLength! * i) - pixelsPerOneMM! * 5,
                pixelsPerOneCM! * 0.2));
        // }
        // printMin = !printMin;
        canvas.drawLine(
            Offset(xOrigin + (xDivLength! * i), paddingTop),
            Offset(xOrigin + (xDivLength! * i), yOrigin),
            graphGridMainLines);
      }
    }
  }

  /// Draws the main y-axis with grid lines and BPM labels
  void drawYAxis(Canvas canvas) {
    //y-axis outlines
    canvas.drawLine(Offset(xOrigin, yOrigin),
        Offset(screenWidth - paddingRight, yOrigin), graphOutlines);
    canvas.drawLine(Offset(xOrigin, paddingTop),
        Offset(screenWidth - paddingRight, paddingTop), graphOutlines);

    int interval = 10;
    int ymin = 50;

    for (int i = 1; i <= yDiv; i++) {
      if (i % 2 == 0) {
        canvas.drawLine(
            Offset(xOrigin, yOrigin - (yDivLength * i)),
            Offset(xOrigin + xAxisLength, yOrigin - (yDivLength * i)),
            graphGridLines);

        canvas.drawParagraph(
            getParagraph((ymin + (interval * (i - 1))).truncate().toString()),
            Offset(pixelsPerOneMM! * 2,
                yOrigin - (yDivLength * i + (pixelsPerOneMM! * 3))));

        canvas.drawLine(
            Offset(xOrigin, yOrigin - (yDivLength * i) + yDivLength / 2),
            Offset(xOrigin + xAxisLength,
                yOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      } else {
        canvas.drawLine(
            Offset(xOrigin, yOrigin - (yDivLength * i)),
            Offset(xOrigin + xAxisLength, yOrigin - (yDivLength * i)),
            graphGridSubLines);

        canvas.drawLine(
            Offset(xOrigin, yOrigin - (yDivLength * i) + yDivLength / 2),
            Offset(xOrigin + xAxisLength,
                yOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      }
    }
  }

  /// Draws the TOCO x-axis with grid lines
  void drawTocoXAxis(Canvas canvas) {
    //int numberOffset = XDIV*(pageNumber);
    for (int j = 1; j < 2; j++) {
      canvas.drawLine(
          Offset(xOrigin + ((xDivLength! / 2) * j), yTocoEnd),
          Offset(xOrigin + ((xDivLength! / 2) * j), yTocoOrigin),
          graphGridSubLines);
    }

    for (int i = 1; i <= xDiv; i++) {
      canvas.drawLine(Offset(xOrigin + (xDivLength! * i), yTocoEnd),
          Offset(xOrigin + (xDivLength! * i), yTocoOrigin), graphGridLines);

      //for (int j = 1; j < 2; j++) `{
      canvas.drawLine(
          Offset(xOrigin + (xDivLength! * i) + xDivLength! / 2, yTocoEnd),
          Offset(
              xOrigin + (xDivLength! * i) + xDivLength! / 2, yTocoOrigin),
          graphGridSubLines);
      //}

      if ((i + mOffset / 60) % gridPerMin! == 0) {
        canvas.drawLine(
            Offset(xOrigin + (xDivLength! * i), yTocoEnd),
            Offset(xOrigin + (xDivLength! * i), yTocoOrigin),
            graphGridMainLines);
      }
    }
  }

  /// Draws the TOCO y-axis with grid lines and pressure labels
  void drawTocoYAxis(Canvas canvas) {
    //y-axis outlines
    canvas.drawLine(Offset(xOrigin, yTocoOrigin),
        Offset(screenWidth - paddingRight, yTocoOrigin), graphOutlines);
    canvas.drawLine(Offset(xOrigin, yTocoEnd),
        Offset(screenWidth - paddingRight, yTocoEnd), graphOutlines);

    int interval = 10;
    int ymin = 10;

    for (int i = 1; i <= yTocoDiv; i++) {
      if (i % 2 == 0) {
        canvas.drawLine(
            Offset(xOrigin, yTocoOrigin - (yDivLength * i)),
            Offset(xOrigin + xAxisLength, yTocoOrigin - (yDivLength * i)),
            graphGridLines);

        canvas.drawParagraph(
            getParagraph((ymin + (interval * (i - 1))).toString()),
            Offset(pixelsPerOneMM! * 2,
                yTocoOrigin - (yDivLength * i + (pixelsPerOneMM! * 3))));

        canvas.drawLine(
            Offset(
                xOrigin, yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            Offset(xOrigin + xAxisLength,
                yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      } else {
        canvas.drawLine(
            Offset(xOrigin, yTocoOrigin - (yDivLength * i)),
            Offset(xOrigin + xAxisLength, yTocoOrigin - (yDivLength * i)),
            graphGridSubLines);
        canvas.drawLine(
            Offset(
                xOrigin, yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            Offset(xOrigin + xAxisLength,
                yTocoOrigin - (yDivLength * i) + yDivLength / 2),
            graphGridSubLines);
      }
    }
  }


  /// Draws data points and connecting lines for BPM measurements
  void drawBPMLine(Canvas canvas, List<int>? list, Paint? lineStyle) {
    if (list == null || list.isEmpty) {
      return;
    }

    double startX, startY, stopX = 0, stopY = 0;
    int startData, stopData = 0;

    int i = mOffset;
    for (; i < list.length - 1 && i < (mOffset + pointsPerPage); i++) {
      startData = stopData;
      stopData = list[i];

      startX = stopX;
      startY = stopY;

      stopX = getScreenX(i);
      stopY = getYValueFromBPM(list[i]); // getScreenY(stopData);

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

      canvas.drawLine(
          Offset(startX, startY), Offset(stopX, stopY), lineStyle!);
    }
  }

  /// Draws data points and connecting lines for MHR measurements
  void drawMHRLine(Canvas canvas, List<int>? list, Paint? lineStyle) {
    if (list == null || list.isEmpty) {
      return;
    }

    double startX, startY, stopX = 0, stopY = 0;
    int startData, stopData = 0;

    int i = mOffset;
    for (; i < list.length - 1 && i < (mOffset + pointsPerPage); i++) {
      startData = stopData;
      stopData = list[i];

      startX = stopX;
      startY = stopY;

      stopX = getScreenX(i);
      stopY = getYValueFromBPM(list[i]); // getScreenY(stopData);

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

      canvas.drawLine(
          Offset(startX, startY), Offset(stopX, stopY), lineStyle!);
    }
  }

  /// Draws movement markers on the graph
  void drawMovements(Canvas canvas) {
    //List<int> movementList = [2, 12, 24,60, 120, 240, 300, 420, 600,690,1000,1100,1140, 1220, 1240, 1300, 1420, 1600];
    List<int>? movementList = test!.movementEntries;
    if (movementList == null || movementList.isEmpty) return;
    /*if (movementList == null && movementList.size() > 0)
            return;*/

    double increment = (pixelsPerOneMM! / timeScaleFactor);
    for (int i = 0; i < movementList.length; i++) {
      int movement = movementList[i];
      if (movement > 0 &&
          movement > mOffset &&
          movement < (mOffset + pointsPerPage)) {
        movement -= mOffset;
        canvas.drawLine(
            Offset(xOrigin + (increment * (movement)),
                yOrigin + pixelsPerOneMM! * 2),
            Offset(xOrigin + (increment * (movement)),
                yOrigin + pixelsPerOneMM! * 2 + (pixelsPerOneMM! * 4)),
            graphOutlines);
        canvas.drawLine(
            Offset(xOrigin + (increment * (movement)),
                yOrigin + pixelsPerOneMM! * 2),
            Offset(xOrigin + (increment * (movement)) + pixelsPerOneMM!,
                yOrigin + pixelsPerOneMM! * 2 + (pixelsPerOneMM! * 2)),
            graphOutlines);
      }
    }

    //Testing dummy movements
    /* for (int pageNumber = 0;pageNumber<pages;pageNumber++) {
            int move[] = {2, 12, 24,60, 120, 240, 300, 420, 600,690, 1220, 1240, 1300, 1420, 1600};
            for (int i = 0; i < move.length; i++) {

               if (move[i]-(pageNumber*pointsPerPage) > 0 && move[i]-(pageNumber*pointsPerPage) < pointsPerPage)
                    canvas.drawBitmap(movementBitmap,
                            xOrigin+(pixelsPerOneMM/timeScaleFactor*(move[i]-(pageNumber*pointsPerPage))-(movementBitmap.getWidth()/2)),
                            yOrigin+pixelsPerOneMM, null);


            }
        }*/
  }


  /// Draws auto-detected movement markers on the graph
  /// [canvas] is the canvas to draw on.
  void drawAutoMovements(Canvas canvas) {
    //List<int> movementList = [2, 12, 24,60, 120, 240, 300, 420, 600,690,1000,1100,1140, 1220, 1240, 1300, 1420, 1600];
    List<int>? movementList = test!.autoFetalMovement;
    if (movementList == null || movementList.isEmpty) return;
    /*if (movementList == null && movementList.size() > 0)
            return;*/

    double increment = (pixelsPerOneMM! / timeScaleFactor);
    for (int i = 0; i < movementList.length; i++) {
      int movement = movementList[i];
      if (movement > 0 &&
          movement > mOffset &&
          movement < (mOffset + pointsPerPage)) {
        movement -= mOffset;
        canvas.drawLine(
            Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneCM! + pixelsPerOneMM!),
            Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneMM! * 3),
            graphOutlines);
        canvas.drawLine(
            Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneCM! + pixelsPerOneMM!),
            Offset(
                xOrigin +
                    (increment * (movement)) +
                    pixelsPerOneMM! +
                    pixelsPerOneMM!,
                yOrigin - pixelsPerOneMM! * 7),
            graphOutlines);
        canvas.drawLine(
            Offset(xOrigin + (increment * (movement)),
                yOrigin - pixelsPerOneCM! + pixelsPerOneMM! * 7),
            Offset(
                xOrigin +
                    (increment * (movement)) +
                    pixelsPerOneMM! +
                    pixelsPerOneMM!,
                yOrigin - pixelsPerOneMM! * 5),
            graphOutlines);

      }
    }

    //Testing dummy movements
    /* for (int pageNumber = 0;pageNumber<pages;pageNumber++) {
            int move[] = {2, 12, 24,60, 120, 240, 300, 420, 600,690, 1220, 1240, 1300, 1420, 1600};
            for (int i = 0; i < move.length; i++) {

               if (move[i]-(pageNumber*pointsPerPage) > 0 && move[i]-(pageNumber*pointsPerPage) < pointsPerPage)
                    canvas.drawBitmap(movementBitmap,
                            xOrigin+(pixelsPerOneMM/timeScaleFactor*(move[i]-(pageNumber*pointsPerPage))-(movementBitmap.getWidth()/2)),
                            yOrigin+pixelsPerOneMM, null);


            }
        }*/
  }

  /// Draws data points and connecting lines for TOCO measurements
  /// [canvas] is the canvas to draw on.
  void drawTocoLine(Canvas canvas) {
    if (test!.tocoEntries == null || test!.tocoEntries!.isEmpty) {
      return;
    }

    double startX, startY, stopX = 0, stopY = 0;
    int startData, stopData = 0;

    int i = mOffset;
    stopX = getScreenXToco(i);
    stopY = getYValueFromToco(test!.tocoEntries![i]);
    for (;
    i < test!.tocoEntries!.length - 1 && i < (mOffset + pointsPerPage);
    i++) {
      startData = stopData;
      stopData = test!.tocoEntries![i];

      startX = stopX;
      startY = stopY;

      stopX = getScreenXToco(i);
      stopY = getYValueFromToco(test!.tocoEntries![i]); // getScreenY(stopData);

      if (i < 1) continue;
      /*if (Math.abs(startData - stopData) > 150) {
                continue;
            }*/

      // a. If the value is 0, it is not drawn
      // b. If the results of the two values before and after are different by more than 30, they are not connected.

      canvas.drawLine(
          Offset(startX, startY), Offset(stopX, stopY), graphBpmLine!);
    }
  }

  /// Draws interpretation areas on the graph
  /// [canvas] is the canvas to draw on.
  /// [list] is the list of marker indices.
  /// [zoneStyle] is the paint style for the zone.
  void drawInterpretationAreas(
      Canvas canvas, List<MarkerIndices>? list, Paint? zoneStyle) {
    if (list == null || list.isEmpty) {
      return;
    }

    double startX, stopX = 0;

    for (int i = 0; i < list.length; i++) {
      startX = getScreenX(list[i].getFrom());
      stopX = getScreenX(list[i].getTo());

      //Marker
      Rect zoneRect =
      Rect.fromLTRB(startX, paddingTop, stopX, yTocoOrigin); //50
      canvas.drawRect(zoneRect, zoneStyle!);
    }
  }

/*  void drawDecelerationAreas(Canvas canvas,List<MarkerIndices> list) {
    if (list == null || list.length<=0) {
      return;
    }

    double startX, stopX = 0;

    for (int i = 0; i < list.length; i++) {

      startX = getScreenX(list[i].getFrom());
      stopX = getScreenX(list[i].getTo());


      //Marker
      Rect zoneRect = new Rect.fromLTRB(startX,
          paddingTop,
          stopX,
          yTocoOrigin );//50
      canvas.drawRect(zoneRect, graphSafeZone);
    }
  }

  void drawNoiseAreas(Canvas canvas,List<MarkerIndices> list) {
    if (list == null || list.length<=0) {
      return;
    }

    double startX, stopX = 0;

    for (int i = 0; i < list.length; i++) {

      startX = getScreenX(list[i].getFrom());
      stopX = getScreenX(list[i].getTo());


      //Marker
      Rect zoneRect = new Rect.fromLTRB(startX,
          paddingTop,
          stopX,
          yTocoOrigin );//50
      canvas.drawRect(zoneRect, graphSafeZone);
    }
  }*/


  /// Calculates screen x-coordinate from data index
  double getScreenX(int i) {
    double k = xOrigin + mIncrement;
    k += mIncrement * (i - mOffset);
    return k;
  }

  /// Calculates screen x-coordinate for TOCO data from data index
  /// [i] is the data index.
  /// Returns the x-coordinate on the screen.
  double getScreenXToco(int i) {
    double k = xOrigin + mIncrement;
    k += mIncrement * (i - mOffset);
    return k;
  }


  /// Converts BPM value to screen y-coordinate
  double getYValueFromBPM(int bpm) {
    double adjustedBPM = (bpm - scaleOrigin).toDouble();
    adjustedBPM = adjustedBPM / 2; //scaled down version for mobile phone
    double yValue = yOrigin - (adjustedBPM * pixelsPerOneMM!);
    //Log.i("bpmvalue", bpm + " " + adjustedBPM + " " + y_value);
    return yValue;
  }

  /// Converts TOCO value to screen y-coordinate
  /// [bpm] is the TOCO value.
  /// Returns the y-coordinate on the screen.
  double getYValueFromToco(int bpm) {
    double adjustedBPM = bpm.toDouble();
    adjustedBPM = adjustedBPM / 2; //scaled down version for mobile phone
    double yValue = yTocoOrigin - (adjustedBPM * pixelsPerOneMM!);
    //Log.i("bpmvalue", bpm + " " + adjustedBPM + " " + y_value);
    return yValue;
  }

  /// Ensures offset stays within valid range
  /// [pos] is the proposed offset value.
  /// Returns clamped offset between 0 and maximum data points.
  int trap(int pos) {
    if (pos < 0) return 0;
    int max = test!.bpmEntries!.length + pointsPerDiv - pointsPerPage;
    if (max < 0) max = 0;

    if (pos > max) pos = max;

    if (pos != 0) pos = pos - (pos % pointsPerDiv);

    debugPrint("$pos   $pointsPerPage   $pointsPerDiv");

    return pos;
  }
}
