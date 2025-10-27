import 'package:fetosense_device_flutter/presentation/widgets/pdf_base_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get_it/get_it.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/intrepretations2.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:mockito/mockito.dart';

class MockTest extends Mock implements Test {}

class MockInterpretations2 extends Mock implements Interpretations2 {}

class MockPreferenceHelper extends Mock implements PreferenceHelper {}

void main() {
  group('PfdBasePage', () {
    late Test mockTestData;
    late Interpretations2 mockInterpretation1;
    late Interpretations2 mockInterpretation2;
    late PreferenceHelper mockPreferenceHelper;

    setUp(() {
      GetIt.I.registerSingleton<PreferenceHelper>(MockPreferenceHelper());
      mockPreferenceHelper = GetIt.I<PreferenceHelper>();

      mockTestData = Test.withData(
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

      mockInterpretation1 = Interpretations2.fromMap(mockTestData);

      mockInterpretation2 = Interpretations2.fromMap(mockTestData);

      when(mockPreferenceHelper.getInt('scale')).thenReturn(1);
    });

    tearDown(() {
      GetIt.I.reset();
    });

    test('PfdBasePage renders correctly', () {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => PfdBasePage(
            index: 1,
            total: 2,
            data: mockTestData,
            interpretation: mockInterpretation1,
            interpretation2: mockInterpretation2,
            body: pw.Container(child: pw.Text('Test Body')),
          ),
        ),
      );

      // A basic check to ensure no exceptions are thrown during PDF generation.
      expect(pdf.save(), isNotNull);
    });

    test('splitTextIntoLines splits text correctly', () {
      const text =
          'This is a long text that needs to be split into multiple lines for the PDF document.';
      final lines = splitTextIntoLines(text, 2, 100, 5);
      expect(lines.length, 2);
      expect(lines[0], 'This is a long text');
      expect(lines[1], 'that needs to be split');
    });

    test('HeaderData displays title and content', () {
      final headerData =
      HeaderData(title: 'Test Title', content: 'Test Content');
      expect(headerData, isA<pw.StatelessWidget>());
    });

    test('Footer displays disclaimer and page number', () {
      final footer = Footer(page: 1, total: 2);
      expect(footer, isA<pw.StatelessWidget>());
    });
  });
}
