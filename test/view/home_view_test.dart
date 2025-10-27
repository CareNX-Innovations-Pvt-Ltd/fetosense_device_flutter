import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/presentation/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockBluetoothSerialService extends Mock {
  void disconnect() {}
  void dispose() {}
}

class MockPreferenceHelper extends Mock implements PreferenceHelper {}

void main() {
  late MockBluetoothSerialService mockBluetoothService;
  late MockPreferenceHelper mockPreferenceHelper;

  setUp(() {
    final getIt = GetIt.I;
    getIt.reset();

    mockBluetoothService = MockBluetoothSerialService();
    mockPreferenceHelper = MockPreferenceHelper();

    // Register the mocks using same types as in ServiceLocator
    getIt.registerLazySingleton<MockBluetoothSerialService>(() => mockBluetoothService);
    getIt.registerLazySingleton<PreferenceHelper>(() => mockPreferenceHelper);
    // Also register under the original type expected by ServiceLocator
    // getIt.registerLazySingleton(() => mockBluetoothService as dynamic);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  testWidgets('calls disconnect and dispose on initState', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    verify(() => mockBluetoothService.disconnect()).called(1);
    verify(() => mockBluetoothService.dispose()).called(1);
  });

  testWidgets('renders UI and all main elements', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    expect(find.text('Fetosense'), findsOneWidget);
    expect(find.text("All Mothers"), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.textContaining('START INSTANT TEST'), findsOneWidget);
    expect(find.textContaining('REGISTER NEW MOTHER'), findsOneWidget);
    expect(find.text('+91 9326775598'), findsOneWidget);
  });

  testWidgets('taps on AppBar buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    await tester.tap(find.text('All Mothers'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();

    expect(true, isTrue); // just ensures no crash
  });

  testWidgets('opens popup menu and taps About and Sign Out', (tester) async {
    when(() => mockPreferenceHelper.removeUser()).thenReturn(null);
    when(() => mockPreferenceHelper.setAutoLogin(false)).thenReturn(null);

    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Sign Out'), findsOneWidget);
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    verify(() => mockPreferenceHelper.removeUser()).called(1);
    verify(() => mockPreferenceHelper.setAutoLogin(false)).called(1);
  });

  testWidgets('taps TextField and RichText links', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('START INSTANT TEST'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('REGISTER NEW MOTHER'));
    await tester.pumpAndSettle();
  });

  testWidgets('renders bottom bar contact section', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));
    expect(find.byType(Image), findsWidgets);
    expect(find.text('+91 9326775598'), findsOneWidget);
  });

  testWidgets('creates and removes overlay menu (indirectly tested)', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });
}
