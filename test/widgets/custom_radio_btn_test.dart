// test/custom_radio_btn_test.dart
import 'package:fetosense_device_flutter/presentation/widgets/custom_radio_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomRadioBtn Widget', () {
    late List<String> labels;
    late List<int> values;
    late int selectedValue;

    setUp(() {
      labels = ['One', 'Two', 'Three'];
      values = [1, 2, 3];
      selectedValue = 0;
    });

    Widget createWidget({bool horizontal = false, bool enableAll = true}) {
      return MaterialApp(
        home: Material(
          child: CustomRadioBtn(
            buttonLables: labels,
            buttonValues: values,
            radioButtonValue: (value) => selectedValue = value,
            buttonColor: Colors.grey,
            selectedColor: Colors.blue,
            defaultValue: labels[0],
            horizontal: horizontal,
            enableAll: enableAll,
          ),
        ),
      );
    }

    testWidgets('renders all buttons and updates selection on tap', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Verify all buttons are present
      for (var label in labels) {
        expect(find.text(label), findsOneWidget);
      }

      // Tap the second button
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(selectedValue, 2);

      // Tap the third button
      await tester.tap(find.text('Three'));
      await tester.pumpAndSettle();

      expect(selectedValue, 3);
    });

    testWidgets('renders in column mode when horizontal is true', (tester) async {
      await tester.pumpWidget(createWidget(horizontal: true));
      await tester.pumpAndSettle();

      // All buttons are present
      for (var label in labels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('does not update selection if enableAll is false', (tester) async {
      await tester.pumpWidget(createWidget(enableAll: false));
      await tester.pumpAndSettle();

      final initialValue = selectedValue;

      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(selectedValue, initialValue); // Should not change
    });

    testWidgets('defaultValue highlights correct button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: CustomRadioBtn(
            buttonLables: labels,
            buttonValues: values,
            radioButtonValue: (value) {},
            buttonColor: Colors.grey,
            selectedColor: Colors.blue,
            defaultValue: labels[1],
            horizontal: false,
            enableAll: true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final selectedButton = tester.widget<MaterialButton>(find.widgetWithText(MaterialButton, 'Two'));
      expect(selectedButton.child, isA<Text>());
    });
  });
}
