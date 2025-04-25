import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fetosense_device_flutter/presentation/test/test_view.dart';

/// widget test for TestView
void main() {
  ServiceLocator.setupLocator();
  // ServiceLocator.sharedPrefsHelper;

  testWidgets('TestView renders correctly and starts test', (WidgetTester tester) async {
    PreferenceHelper.init();
    await tester.pumpWidget(
      const MaterialApp(
        home: TestView(),
      ),
    );

    // Assert initial state
    expect(find.text('START'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    // Act: Tap the start button
    await tester.tap(find.text('START'));
    await tester.pump();

    // Assert: Test started
    expect(find.byIcon(Icons.stop), findsOneWidget);
  });
}



// void main() {
//   test('startTest updates state correctly', () {
//     // Arrange
//     final state = TestViewState();
//
//     // Act
//     state.startTest();
//
//     // Assert
//     expect(state.isTestRunning, true);
//     expect(state.hasTestStarted, true);
//     expect(state.startTest, isNotNull);
//   });
// }