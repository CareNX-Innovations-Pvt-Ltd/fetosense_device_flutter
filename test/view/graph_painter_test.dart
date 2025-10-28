import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/graph/graph_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCanvas extends Mock implements Canvas {}

void main() {
  late GraphPainter painter;
  late Test testData;
  late MockCanvas canvas;

  setUp(() {
    testData = Test()
      ..bpmEntries = [60, 70, 80, 90, 100]
      ..bpmEntries2 = [65, 75, 85, 95, 105]
      ..mhrEntries = [120, 125, 130, 135, 140]
      ..tocoEntries = [10, 20, 30, 40, 50]
      ..movementEntries = [1, 3, 5]
      ..autoFetalMovement = [2, 4, 6];

    painter = GraphPainter(testData, 0, 3, null, false);
    canvas = MockCanvas();
  });

  test('paint() initializes and draws without exceptions', () {
    const size = Size(300, 500);
    expect(() => painter.paint(canvas, size), returnsNormally);
  });

  test('getScreenX returns correct value', () {
    painter.mIncrement = 1;
    painter.xOrigin = 10;
    painter.mOffset = 0;
    final x = painter.getScreenX(5);
    expect(x, 16); // 10 + 1 + 1*(5-0)
  });

  test('getScreenXToco returns correct value', () {
    painter.mIncrement = 2;
    painter.xOrigin = 10;
    painter.mOffset = 1;
    final x = painter.getScreenXToco(4);
    expect(x, 18); // 10 +2 + 2*(4-1)
  });

  test('getYValueFromBPM converts bpm to y-coordinate', () {
    painter.yOrigin = 200;
    painter.pixelsPerOneMM = 1;
    painter.scaleOrigin = 40;
    final y = painter.getYValueFromBPM(60);
    expect(y, 190); // (60-40)/2 = 10; 200-10 = 190
  });

  test('getYValueFromToco converts to y-coordinate', () {
    painter.yTocoOrigin = 100;
    painter.pixelsPerOneMM = 2;
    final y = painter.getYValueFromToco(50);
    expect(y, 50); // 50/2=25; 100-25*2=50
  });

  test('trap clamps offset correctly', () {
    painter.pointsPerDiv = 10;
    painter.pointsPerPage = 5;
    painter.test!.bpmEntries = List.generate(20, (index) => index);
    expect(painter.trap(-5), 0);
    expect(painter.trap(100), greaterThanOrEqualTo(0));
    expect(painter.trap(8) % painter.pointsPerDiv, 0);
  });

  test('drawBPMLine handles empty and null lists', () {
    painter.pointsPerPage = 10;
    painter.mOffset = 0;
    expect(() => painter.drawBPMLine(canvas, [], painter.graphBpmLine), returnsNormally);
    expect(() => painter.drawBPMLine(canvas, null, painter.graphBpmLine), returnsNormally);
  });

  test('drawMHRLine handles empty and null lists', () {
    painter.pointsPerPage = 10;
    painter.mOffset = 0;
    expect(() => painter.drawMHRLine(canvas, [], painter.graphMHRLine), returnsNormally);
    expect(() => painter.drawMHRLine(canvas, null, painter.graphMHRLine), returnsNormally);
  });

  test('drawMovements and drawAutoMovements run without exceptions', () {
    painter.mOffset = 0;
    painter.pointsPerPage = 10;
    painter.pixelsPerOneMM = 1;
    painter.yOrigin = 100;
    painter.xOrigin = 10;

    expect(() => painter.drawMovements(canvas), returnsNormally);
    expect(() => painter.drawAutoMovements(canvas), returnsNormally);
  });

  test('drawTocoLine runs without exceptions', () {
    painter.mOffset = 0;
    painter.pointsPerPage = 10;
    painter.pixelsPerOneMM = 1;
    painter.yTocoOrigin = 100;
    painter.xOrigin = 10;

    expect(() => painter.drawTocoLine(canvas), returnsNormally);
  });

  test('drawInterpretationAreas handles null and empty', () {
    expect(() => painter.drawInterpretationAreas(canvas, null, painter.graphSafeZone), returnsNormally);
    expect(() => painter.drawInterpretationAreas(canvas, [], painter.graphSafeZone), returnsNormally);
  });

  test('shouldRepaint returns true if offset changed', () {
    final old = GraphPainter(testData, 1, 3, null, false);
    expect(painter.shouldRepaint(old), true);
  });

  test('shouldRepaint returns false if offset same', () {
    final old = GraphPainter(testData, 0, 3, null, false);
    expect(painter.shouldRepaint(old), false);
  });
}
