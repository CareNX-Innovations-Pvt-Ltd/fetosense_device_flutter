import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/presentation/test/test_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PreferenceHelper.init();
    ServiceLocator.setupLocator();
  });

  testWidgets('TestView renders correctly with initial state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TestView(),
      ),
    );

    // Verify initial UI elements
    expect(find.text('START'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.text('Test duration:'), findsOneWidget);
  });

  testWidgets('TestView starts test on START button tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TestView(),
      ),
    );

    // Tap the START button
    await tester.tap(find.text('START'));
    await tester.pump();

    // Verify test started
    expect(find.byIcon(Icons.stop), findsOneWidget);
  });

  testWidgets('TestView stops test on STOP button tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TestView(),
      ),
    );

    // Start the test
    await tester.tap(find.text('START'));
    await tester.pump();

    // Stop the test
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();

    // Verify test stopped
    expect(find.text('START'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('TestView updates dropdown value', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TestView(),
      ),
    );

    // Open dropdown and select a new value
    await tester.tap(find.text('20 min'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10 min').last);
    await tester.pump();

    // Verify dropdown value updated
    expect(find.text('10 min'), findsOneWidget);
  });
}