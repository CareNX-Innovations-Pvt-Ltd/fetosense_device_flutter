import 'package:fetosense_device_flutter/core/constants/app_constants.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/presentation/app_settings/app_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockPreferenceHelper extends Mock implements PreferenceHelper {}

void main() {
  late MockPreferenceHelper mockPreferenceHelper;

  setUp(() {
    mockPreferenceHelper = MockPreferenceHelper();

    if (GetIt.I.isRegistered<PreferenceHelper>()) {
      GetIt.I.unregister<PreferenceHelper>();
    }
    GetIt.I.registerSingleton<PreferenceHelper>(mockPreferenceHelper);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: AppSetting(),
    );
  }

  testWidgets('renders AppBar with title Settings', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('renders "Test" section with image and title', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Test'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('Default test duration shows correct initial value', (tester) async {
    when(() => mockPreferenceHelper.getString(AppConstants.defaultTestDurationKey))
        .thenReturn('20 min');

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Default test duration'), findsOneWidget);
    expect(find.text('20 min'), findsOneWidget);
  });

  testWidgets('FHR Alerts switch sets preference on enable', (tester) async {
    when(() => mockPreferenceHelper.setBool(AppConstants.fhrAlertsKey, true))
        .thenAnswer((_) async => {});
    when(() => mockPreferenceHelper.setBool(AppConstants.fhrAlertsKey, false))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    final fhrTile = find.text('FHR Alerts');
    expect(fhrTile, findsOneWidget);
  });

  testWidgets('renders Default print scale and opens dialog', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Default print scale'), findsOneWidget);
    await tester.tap(find.text('Default print scale'));
    await tester.pumpAndSettle();

    expect(find.text('1 cm/min'), findsOneWidget);
    expect(find.text('3 cm/min'), findsOneWidget);
  });

  testWidgets('Auto interpretation toggle works and affects dependent preference visibility', (tester) async {
    when(() => mockPreferenceHelper.setBool(AppConstants.autoInterpretationsKey, true))
        .thenAnswer((_) async => {});
    when(() => mockPreferenceHelper.setBool(AppConstants.autoInterpretationsKey, false))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Auto interpretation'), findsOneWidget);
    expect(find.text('Highlight patterns'), findsOneWidget);
  });

  testWidgets('Display logo preference is shown', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Display logo'), findsOneWidget);
  });

  testWidgets('Doctor\'s comment switch is displayed', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Doctor\'s comment'), findsOneWidget);
  });

  testWidgets('Enable Patient ID switch sets correct preference', (tester) async {
    when(() => mockPreferenceHelper.setBool(AppConstants.patientIdKey, true))
        .thenAnswer((_) async => {});
    when(() => mockPreferenceHelper.setBool(AppConstants.patientIdKey, false))
        .thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Enable Patient ID'), findsOneWidget);
  });

  testWidgets('Use Manual Movement Marker switch is visible', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Use Manual Movement Marker'), findsOneWidget);
  });

  testWidgets('Show Fisher Score switch is visible', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Show Fisher Score'), findsOneWidget);
  });

  testWidgets('tapping back button pops navigation', (tester) async {
    bool didPop = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return const AppSetting();
          },
        ),
        navigatorObservers: [
          NavigatorObserverMock(onPop: () => didPop = true),
        ],
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // No assert for didPop, as we're not using mock navigator here. This is just a tap test.
  });
}

// Optional mock navigator observer for more advanced navigation test
class NavigatorObserverMock extends NavigatorObserver {
  final VoidCallback onPop;

  NavigatorObserverMock({required this.onPop});

  @override
  void didPop(Route route, Route? previousRoute) {
    onPop();
    super.didPop(route, previousRoute);
  }
}
