import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_device_flutter/presentation/widgets/date_picker_widget.dart';

void main() {
  // A test controller to be used across tests
  late TextEditingController testController;

  // A helper function to build the widget within a MaterialApp
  // This is necessary to provide context for dialogs and themes.
  Widget createTestableWidget({
    required TextEditingController controller,
    String label = "Select Date",
    Function(DateTime)? onDateSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DatePickerTextField(
          controller: controller,
          label: label,
          onDateSelected: onDateSelected,
        ),
      ),
    );
  }

  // Initialize the controller before each test
  setUp(() {
    testController = TextEditingController();
  });

  // Dispose of the controller after each test to prevent memory leaks
  tearDown(() {
    testController.dispose();
  });

  group('DatePickerTextField', () {
    testWidgets('renders correctly with initial properties', (
        WidgetTester tester) async {
      // Arrange
      const labelText = "Last Menstrual Period";

      // Act
      await tester.pumpWidget(createTestableWidget(
        controller: testController,
        label: labelText,
      ));

      // Assert
      // Find the TextFormField by its label
      final textFieldFinder = find.widgetWithText(TextFormField, labelText);
      expect(textFieldFinder, findsOneWidget);

      // Verify that it's read-only
      final textField = tester.widget<TextFormField>(textFieldFinder);
      expect(textField.enabled, isTrue);

      // Check for the calendar icon
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);

      // The controller's text should be empty initially
      expect(testController.text, isEmpty);
    });

    testWidgets(
        'opens date picker dialog when tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget(
        controller: testController,
      ));

      // Act
      // Tap the TextFormField to trigger the date picker
      await tester.tap(find.byType(TextFormField));
      await tester.pump(); // First pump to start the dialog animation

      // Assert
      // The date picker dialog should now be on screen
      expect(find.byType(Dialog), findsOneWidget);

      // Verify that the current year is visible in the picker, confirming it opened
      expect(find.text(DateTime
          .now()
          .year
          .toString()), findsOneWidget);
    });

    testWidgets(
        'updates controller and calls onDateSelected when a date is picked', (
        WidgetTester tester) async {
      // Arrange
      DateTime? capturedDate;

      await tester.pumpWidget(createTestableWidget(
        controller: testController,
        onDateSelected: (date) {
          capturedDate = date;
        },
      ));

      // The date we will choose in the picker.
      // Use a known date to avoid issues with `DateTime.now()`
      final testDate = DateTime.now().subtract(const Duration(days: 10));

      // Act
      // 1. Open the dialog
      await tester.tap(find.byType(TextFormField));
      await tester
          .pumpAndSettle(); // pumpAndSettle waits for animations to finish

      // 2. Tap the specific day in the picker
      await tester.tap(find.text(testDate.day.toString()));
      await tester.pumpAndSettle();

      // 3. Tap the 'OK' button to confirm selection
      await tester.tap(find.text('OK'));
      await tester
          .pumpAndSettle(); // Wait for the dialog to close and state to update

      // Assert
      // Verify the controller's text was updated with the formatted date
      expect(testController.text,
          '${testDate.day.toString().padLeft(2, '0')}-${testDate.month
              .toString().padLeft(2, '0')}-${testDate.year}');

      // Verify the callback was triggered with the correct date
      expect(capturedDate, isNotNull);
      expect(
        capturedDate,
        equals(DateTime(testDate.year, testDate.month,
            testDate.day)), // Compare date part only
      );

      // The dialog should be gone
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets(
        'does not update controller or call callback if date picker is cancelled', (
        WidgetTester tester) async {
      // Arrange
      bool wasCallbackCalled = false;

      await tester.pumpWidget(createTestableWidget(
        controller: testController,
        onDateSelected: (_) {
          wasCallbackCalled = true;
        },
      ));

      // Act
      // 1. Open the dialog
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // 2. Tap the 'CANCEL' button
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      // Assert
      // The controller's text should remain empty
      expect(testController.text, isEmpty);

      // The callback should not have been called
      expect(wasCallbackCalled, isFalse);

      // The dialog should be gone
      expect(find.byType(Dialog), findsNothing);
    });
  });
}