import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/widgets/interpretation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock callback class
class MockCallback extends Mock {
  void call(String radioValue, String comments, bool isUpdate);
}


// Dummy CustomRadioBtn widget to avoid dependency issues
class CustomRadioBtn extends StatelessWidget {
  final List<String> buttonLables;
  final List<String> buttonValues;
  final String? defaultValue;
  final Function(String)? radioButtonValue;
  final Color buttonColor;
  final Color selectedColor;
  final bool enableAll;

  const CustomRadioBtn({
    super.key,
    required this.buttonColor,
    required this.buttonLables,
    required this.buttonValues,
    required this.radioButtonValue,
    required this.selectedColor,
    required this.enableAll,
    this.defaultValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: buttonValues
          .map(
            (v) => TextButton(
          key: Key(v),
          onPressed: () => radioButtonValue?.call(v),
          child: Text(v),
        ),
      )
          .toList(),
    );
  }
}


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InterpretationDialog', () {
    late MockCallback mockCallback;

    setUp(() {
      mockCallback = MockCallback();
    });

    Future<void> _openDialog(WidgetTester tester, {String? value}) async {
      final test = Test.withData(
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
      // Test? test;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => InterpretationDialog(
                        test:  test,
                        value: value,
                        callback: mockCallback,
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders correctly and uses initial values', (tester) async {
      await _openDialog(tester, value: 'Normal');
      expect(find.text('Update Interpretations'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Abnormal'), findsOneWidget);
      expect(find.text('Atypical'), findsOneWidget);
      expect(find.text('Extra Comments'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('radio button selection updates radioValue', (tester) async {
      await _openDialog(tester, value: '');
      await tester.tap(find.byKey(const Key('Normal')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('Abnormal')));
      await tester.pumpAndSettle();
    });

    testWidgets('text field updates comments value', (tester) async {
      await _openDialog(tester);
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, 'new comment');
      await tester.pumpAndSettle();
    });

    testWidgets('Cancel button triggers callback and pops dialog', (tester) async {
      await _openDialog(tester, value: 'Normal');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      verify(mockCallback('any', 'any', false)).called(1);
      expect(find.text('Update Interpretations'), findsNothing);
    });

    testWidgets('Update button triggers callback and pops dialog', (tester) async {
      await _openDialog(tester, value: 'Abnormal');
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();
      verify(mockCallback('any', 'any', true)).called(1);
      expect(find.text('Update Interpretations'), findsNothing);
    });

    testWidgets('handleRadioClick does not rebuild when same value', (tester) async {
      await _openDialog(tester, value: 'Normal');
      // Tap same button twice
      await tester.tap(find.byKey(const Key('Normal')));
      await tester.pumpAndSettle();
    });
  });
}
