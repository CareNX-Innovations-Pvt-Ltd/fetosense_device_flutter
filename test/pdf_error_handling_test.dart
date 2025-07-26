import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/details/details_cubit.dart';
import 'package:fetosense_device_flutter/presentation/widgets/fhr_pdf_view_2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pdf_error_handling_test.mocks.dart';
@GenerateMocks([FhrPdfView2])
void main() {
  // Ensure the binding is initialized
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  ServiceLocator.setupLocator();
  PreferenceHelper.init();

  test('Handles errors during PDF generation', () async {
    // Arrange
    final mockFhrPdfView = MockFhrPdfView2();

    when(mockFhrPdfView.getNSTGraph(any, any))
        .thenThrow(Exception('PDF generation failed'));

    final test = Test.withData(
      id: 'test123',
      documentId: 'doc123',
      motherId: 'mother456',
      deviceId: 'device789',
      doctorId: 'doctor321',
      weight: 65,
      gAge: 36,
      age: 28,
      fisherScore: 8,
      fisherScore2: 7,
      motherName: 'Jane Doe',
      deviceName: 'DeviceX',
      doctorName: 'Dr. Smith',
      patientId: 'patient123',
      organizationId: 'org001',
      organizationName: 'HealthOrg',
      bpmEntries: [120, 125, 118],
      bpmEntries2: [122, 127, 119],
      baseLineEntries: [110, 112, 115],
      movementEntries: [1, 0, 1],
      autoFetalMovement: [0, 1, 1],
      tocoEntries: [30, 35, 40],
      lengthOfTest: 20,
      averageFHR: 122,
      live: true,
      testByMother: false,
      testById: 'tester001',
      interpretationType: 'Auto',
      interpretationExtraComments: 'Normal test result.',
      associations: {'someKey': 'someValue'},
      autoInterpretations: {'risk': 'low'},
      delete: false,
      createdOn: DateTime.now(),
      createdBy: 'adminUser',
    );

    // Act
    final pdfDoc = await DetailsCubit(test).generatePdf(PdfPageFormat.a4, Test());

    // Assert
    expect(pdfDoc.document.pageLabels, true);
  });
}