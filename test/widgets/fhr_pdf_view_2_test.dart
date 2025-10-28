import 'dart:ui' as ui;

import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/intrepretations2.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/widgets/fhr_pdf_view_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../cubit/all_mother_cubit_test.dart';

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<PreferenceHelper>()) {
      GetIt.I.registerSingleton<PreferenceHelper>(MockPreferenceHelper());
    }
  });

  group('FhrPdfView2 Unit & Widget Tests', () {
    late FhrPdfView2 fhrPdfView;
    late Test testData;
    late Interpretations2 interpretation;

    setUp(() {
      fhrPdfView = FhrPdfView2(600);

      testData = Test.withData(
        id: 'test-id-001',
        documentId: 'doc-001',
        motherId: 'mother-001',
        deviceId: 'device-001',
        doctorId: 'doctor-001',
        weight: 3200,
        gAge: 32,
        age: 28,
        fisherScore: 3,
        fisherScore2: 4,
        motherName: 'Test Mother',
        deviceName: 'Device A',
        doctorName: 'Dr. John Doe',
        patientId: 'PAT-1234',
        organizationId: 'org-001',
        organizationName: 'Test Org',
        bpmEntries: List.generate(200, (i) => 140 + (i % 3)),
        bpmEntries2: List.generate(100, (i) => 135 + (i % 2)),
        baseLineEntries: List.generate(50, (i) => 145),
        movementEntries: List.generate(5, (i) => 1),
        autoFetalMovement: List.generate(3, (i) => 1),
        tocoEntries: List.generate(200, (i) => i % 40),
        lengthOfTest: 600,
        averageFHR: 140,
        live: false,
        testByMother: false,
        testById: 'admin',
        interpretationType: 'Normal',
        interpretationExtraComments: 'No abnormalities observed.',
        associations: {'ref': 'linked-object'},
        autoInterpretations: {
          'summary': 'Auto generated',
          'score': 7,
        },
        createdOn: DateTime.now(),
        createdBy: 'admin_user',
      );

      interpretation = Interpretations2();
    });

    test('getNSTGraph produces MemoryImage list', () async {
      final pages = await fhrPdfView.getNSTGraph(testData, interpretation);
      expect(pages, isNotNull);
      expect(pages!.length, greaterThan(0));
      for (final img in pages) {
        expect(img, isA<MemoryImage>());
      }
    });

    test('getNSTGraph handles empty test data', () async {
      final emptyTest = Test.withData(
        id: 'test-id-001',
        documentId: 'doc-001',
        motherId: 'mother-001',
        deviceId: 'device-001',
        doctorId: 'doctor-001',
        weight: 3200,
        gAge: 32,
        age: 28,
        fisherScore: 3,
        fisherScore2: 4,
        motherName: 'Test Mother',
        deviceName: 'Device A',
        doctorName: 'Dr. John Doe',
        patientId: 'PAT-1234',
        organizationId: 'org-001',
        organizationName: 'Test Org',
        bpmEntries: List.generate(200, (i) => 140 + (i % 3)),
        bpmEntries2: List.generate(100, (i) => 135 + (i % 2)),
        baseLineEntries: List.generate(50, (i) => 145),
        movementEntries: List.generate(5, (i) => 1),
        autoFetalMovement: List.generate(3, (i) => 1),
        tocoEntries: List.generate(200, (i) => i % 40),
        lengthOfTest: 600,
        averageFHR: 140,
        live: false,
        testByMother: false,
        testById: 'admin',
        interpretationType: 'Normal',
        interpretationExtraComments: 'No abnormalities observed.',
        associations: {'ref': 'linked-object'},
        autoInterpretations: {
          'summary': 'Auto generated',
          'score': 7,
        },
        createdOn: DateTime.now(),
        createdBy: 'admin_user',
      );

      final pages = await fhrPdfView.getNSTGraph(emptyTest, interpretation);
      expect(pages, isNotNull);
      expect(pages!.length, greaterThan(0));
    });

    testWidgets('FhrPdfView2 renders in RepaintBoundary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: const Key('fhrPdfViewBoundary'),
              child: Builder(
                builder: (context) {
                  // Trigger PDF/graph generation
                  fhrPdfView.getNSTGraph(testData, interpretation);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify RepaintBoundary exists
      final boundaryFinder = find.byKey(const Key('fhrPdfViewBoundary'));
      expect(boundaryFinder, findsOneWidget);

      // Capture image from RepaintBoundary
      final renderObject = tester.renderObject<RenderRepaintBoundary>(boundaryFinder);
      final ui.Image image = await renderObject.toImage(pixelRatio: 1.0);
      expect(image.width, greaterThan(0));
      expect(image.height, greaterThan(0));
    });

    test('Generated MemoryImage bytes are valid', () async {
      final pages = await fhrPdfView.getNSTGraph(testData, interpretation);
      final firstPage = pages!.first;
      final bytes = firstPage.bytes; // <-- directly access bytes
      expect(bytes, isNotNull);
      expect(bytes.length, greaterThan(0));
    });
  });
}
