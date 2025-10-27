import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_device_flutter/presentation/widgets/animated_counter.dart';

void main() {
  group('AnimatedCount', () {
    // Test case 1: Verify the initial value is displayed correctly (or close to it)
    testWidgets('starts animation from 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCount(
              count: 100,
              style: TextStyle(fontSize: 24),
              duration: Duration(seconds: 1),
            ),
          ),
        ),
      );

      // At the very first frame (time t=0), the value should be 0.
      expect(find.text('0'), findsOneWidget);
    });

    // Test case 2: Verify the final value is displayed after the animation completes
    testWidgets(
        'ends animation at the final count', (WidgetTester tester) async {
      const finalCount = 150;
      const animationDuration = Duration(milliseconds: 500);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCount(
              count: finalCount,
              style: TextStyle(fontSize: 24),
              duration: animationDuration,
            ),
          ),
        ),
      );

      // At the first frame, it should be '0'
      expect(find.text('0'), findsOneWidget);
      expect(find.text(finalCount.toString()), findsNothing);

      // Fast-forward the animation by its full duration
      await tester.pump(animationDuration);

      // Now, the animation is complete, and the final count should be displayed.
      expect(find.text('0'), findsNothing);
      expect(find.text(finalCount.toString()), findsOneWidget);
    });

    // Test case 3: Verify that the provided style is applied to the Text widget
    testWidgets('applies the provided text style', (WidgetTester tester) async {
      const testStyle = TextStyle(
        fontSize: 48,
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCount(
              count: 50,
              style: testStyle,
            ),
          ),
        ),
      );

      // Get the Text widget that is displaying the count
      final textWidget = tester.widget<Text>(find.byType(Text));

      // Assert that the style of the Text widget matches the one we provided
      expect(textWidget.style, equals(testStyle));
    });

    // Test case 4: Check intermediate value during animation
    testWidgets('displays an intermediate value during animation', (
        WidgetTester tester) async {
      const finalCount = 100;
      const animationDuration = Duration(seconds: 1);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCount(
              count: finalCount,
              style: TextStyle(fontSize: 24),
              duration: animationDuration,
            ),
          ),
        ),
      );

      // Fast-forward the animation by half its duration
      await tester.pump(const Duration(milliseconds: 500));

      // The value should be roughly halfway between 0 and 100.
      // IntTween will produce an integer result.
      final textWidget = tester.widget<Text>(find.byType(Text));
      final currentValue = int.parse(textWidget.data!);

      // Check if the value is between the start and end, but not the start or end itself
      expect(currentValue, greaterThan(0));
      expect(currentValue, lessThan(100));
      // For a linear IntTween, it should be exactly 50 at the halfway point.
      expect(currentValue, 50);
    });

    // Test case 5: Ensure the default duration is 1 second if not provided
    testWidgets('uses default duration of 1 second when not specified', (
        WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCount(
              count: 100,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      );

      // The TweenAnimationBuilder widget holds the duration property.
      final builder = tester.widget<TweenAnimationBuilder<int>>(
          find.byType(TweenAnimationBuilder<int>));

      // Assert that the duration is the default 1 second.
      expect(builder.duration, const Duration(seconds: 1));
    });
  });
}