import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/presentation/home/home_view.dart';
import 'package:fetosense_device_flutter/presentation/login/login_view.dart';
import 'package:fetosense_device_flutter/presentation/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Navigates to SplashScreen', (WidgetTester tester) async {
    final router = appRouter;

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('Navigates to LoginView', (WidgetTester tester) async {
    final router = appRouter;

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    router.go(AppRoutes.login);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('Navigates to HomeView', (WidgetTester tester) async {
    final router = appRouter;

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    router.go(AppRoutes.home);
    await tester.pumpAndSettle();

    expect(find.byType(HomeView), findsOneWidget);
  });
}
