import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/details/details_cubit.dart';
import 'package:fetosense_device_flutter/presentation/widgets/fhr_pdf_view_2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fetosense_device_flutter/presentation/details/details_view.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFhrPdfView extends Mock implements FhrPdfView2 {}

void main() {
  // Ensure the binding is initialized
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  ServiceLocator.setupLocator();
  PreferenceHelper.init();

  test('Handles errors during PDF generation', () async {
    // Arrange
    final mockFhrPdfView = MockFhrPdfView();

    when(mockFhrPdfView.getNSTGraph(any, any))
        .thenThrow(Exception('PDF generation failed'));

    // Act
    final pdfDoc = await DetailsCubit(Test()).generatePdf(PdfPageFormat.a4, Test());

    // Assert
    expect(pdfDoc.document.pageLabels, true);
  });
}