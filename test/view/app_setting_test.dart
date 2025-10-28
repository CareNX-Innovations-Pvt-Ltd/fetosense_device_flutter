// dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/presentation/app_settings/app_setting.dart';

class MockPreferenceHelper extends Mock implements PreferenceHelper {}

class TestNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPop;
  TestNavigatorObserver({required this.onPop});
  @override
  void didPop(Route route, Route? previousRoute) {
    onPop();
    super.didPop(route, previousRoute);
  }
}

void main() {
  late PreferenceHelper mockPrefs;

  setUp(() {
    mockPrefs = MockPreferenceHelper();
    // Default returns used during initial builds
    when(() => mockPrefs.getString(any())).thenReturn('20 min');
    when(() => mockPrefs.getBool(any())).thenReturn(false);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async {});
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async {});
    GetIt.I.registerSingleton<PreferenceHelper>(mockPrefs);
  });

  tearDown(() {
    GetIt.I.reset();
    resetMocktailState();
  });

  testWidgets('AppSetting builds all widgets and initial texts present', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppSetting()));

    // AppBar
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // Sections
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Printing'), findsOneWidget);

    // Sample switches and labels
    final switches = [
      "FHR Alerts",
      "Use Manual Movement Marker",
      "Enable Patient ID",
      "Show Fisher Score",
      "Doctor's comment",
      "Auto interpretation",
      "Highlight patterns",
      "Display logo",
    ];
    for (var label in switches) {
      expect(find.text(label), findsOneWidget);
    }

    // PreferenceDialogLink labels
    expect(find.text('Default test duration'), findsOneWidget);
    expect(find.text('Default print scale'), findsOneWidget);
  });

  testWidgets('All switches interact correctly and call PreferenceHelper', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppSetting()));

    // FHR Alerts toggle
    await tester.tap(find.text('FHR Alerts'));
    await tester.pump();
    verify(() => mockPrefs.setBool(AppConstants.fhrAlertsKey, true)).called(1);

    // Enable Patient ID toggle
    await tester.tap(find.text('Enable Patient ID'));
    await tester.pump();
    verify(() => mockPrefs.setBool(AppConstants.patientIdKey, true)).called(1);

    // Use Manual Movement Marker toggle
    await tester.tap(find.text('Use Manual Movement Marker'));
    await tester.pump();
    verify(() => mockPrefs.setBool(AppConstants.movementMarkerKey, true)).called(1);

    // Auto interpretation toggles (only triggers setBool via underlying preference)
    await tester.tap(find.text('Auto interpretation'));
    await tester.pump();
    verify(() => mockPrefs.setBool(AppConstants.autoInterpretationsKey, true)).called(1);

    // Display logo toggle - ensure tapping does not crash (onEnable is empty in widget code)
    await tester.tap(find.text('Display logo'));
    await tester.pump();
    // Underlying preference may call setBool; at minimum the tap exercised the branch
  });

  testWidgets('PreferenceDialogLink selects radio options for duration and print scale', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppSetting()));

    // Default test duration: open dialog and select '10 min'
    await tester.tap(find.text('Default test duration'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10 min'));
    await tester.pump();
    // RadioPreference onSelect in this widget triggers setString directly
    verify(() => mockPrefs.setString(AppConstants.defaultTestDurationKey, '10 min')).called(1);

    // Default print scale: open dialog and choose '3 cm/min'
    await tester.tap(find.text('Default print scale'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3 cm/min'));
    await tester.pump();
    // Expect underlying preference saved '3'
    verify(() => mockPrefs.setString(AppConstants.defaultPrintScaleKey, '3')).called(1);
  });

  testWidgets('PreferenceHider hides Highlight patterns when Auto interpretation enabled', (tester) async {
    // Initial build: autoInterpretations false -> '!autoInterpretations' becomes true -> child shown
    when(() => mockPrefs.getBool(AppConstants.autoInterpretationsKey)).thenReturn(false);
    await tester.pumpWidget(const MaterialApp(home: AppSetting()));
    expect(find.text('Highlight patterns'), findsOneWidget);

    // Tap Auto interpretation to enable it
    await tester.tap(find.text('Auto interpretation'));
    await tester.pump();
    verify(() => mockPrefs.setBool(AppConstants.autoInterpretationsKey, true)).called(1);

    // Reconfigure mock to simulate saved preference as true and rebuild widget
    when(() => mockPrefs.getBool(AppConstants.autoInterpretationsKey)).thenReturn(true);
    await tester.pumpWidget(const MaterialApp(home: AppSetting()));
    await tester.pumpAndSettle();

    // Now PreferenceHider condition should hide the child
    expect(find.text('Highlight patterns'), findsNothing);
  });

  testWidgets('Back button pops context', (tester) async {
    bool popped = false;

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppSetting()),
            ),
            child: const Text('Go'),
          ),
        ),
      ),
      navigatorObservers: [TestNavigatorObserver(onPop: () => popped = true)],
    ));

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(popped, isTrue);
  });
}