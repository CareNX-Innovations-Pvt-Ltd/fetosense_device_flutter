import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/presentation/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockPreferenceHelper extends Mock implements PreferenceHelper {}

void main() {
  late MockPreferenceHelper mockPrefs;

  setUp(() {
    mockPrefs = MockPreferenceHelper();
    GetIt.I.registerSingleton<PreferenceHelper>(mockPrefs);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  testWidgets('SplashScreen shows splash image',
          (WidgetTester tester) async {
        when(() => mockPrefs.getAutoLogin()).thenReturn(false);

        await tester.pumpWidget(
          MaterialApp(
            home: const SplashScreen(),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
        expect(find.byType(SplashScreen), findsOneWidget);
      });

  testWidgets('SplashScreen navigates to login when auto login is false',
          (WidgetTester tester) async {
        when(() => mockPrefs.getAutoLogin()).thenReturn(false);

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const SplashScreen(),
            ),
            GoRoute(
              path: AppRoutes.login,
              builder: (context, state) => const Placeholder(key: Key('login')),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('login')), findsOneWidget);
      });

  testWidgets('SplashScreen navigates to home when auto login is true',
          (WidgetTester tester) async {
        when(() => mockPrefs.getAutoLogin()).thenReturn(true);

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const SplashScreen(),
            ),
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const Placeholder(key: Key('home')),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('home')), findsOneWidget);
      });
}
