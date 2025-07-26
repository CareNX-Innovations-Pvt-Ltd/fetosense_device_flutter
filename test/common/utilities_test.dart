import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fetosense_device_flutter/core/utils/utilities.dart';

void main() {
  group('Utilities', () {
    test('getGestationalAgeWeeks should calculate correct gestational age in weeks', () {
      final lmpDate = DateTime(2023, 1, 1);
      final gestationalAgeWeeks = Utilities.getGestationalAgeWeeks(lmpDate);

      final today = DateTime.now();
      final expectedWeeks = (today.difference(lmpDate).inDays / 7).floor();
      expect(gestationalAgeWeeks, expectedWeeks);
    });

    test('getLmpFromGestationalAgeWeeks should calculate correct last menstrual period date', () {
      const gestationalAgeWeeks = 40;
      final lmpDate = Utilities.getLmpFromGestationalAgeWeeks(gestationalAgeWeeks);

      final today = DateTime.now();
      final expectedDate = today.subtract(const Duration(days: gestationalAgeWeeks * 7));

      // Compare date ignoring microseconds
      expect(
        lmpDate.toIso8601String().substring(0, 10),
        expectedDate.toIso8601String().substring(0, 10),
      );
    });

    testWidgets('setScreenUtil should initialize screen size configuration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      final BuildContext context = tester.element(find.byType(SizedBox));
      final utilities = Utilities();

      expect(() => utilities.setScreenUtil(context, width: 360, height: 690), returnsNormally);
    });
  });
}
