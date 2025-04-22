import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_device_flutter/main.dart';
import 'package:preferences/preference_service.dart';

void main() {
  testWidgets('App should start without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    ServiceLocator.setupLocator();
    ServiceLocator.sharedPrefsHelper;
    PrefService.init();
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts without errors
    expect(find.byType(MyApp), findsOneWidget);
  });
}