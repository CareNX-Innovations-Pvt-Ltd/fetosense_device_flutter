import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/data/models/mother_model.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/about/about_view.dart';
import 'package:fetosense_device_flutter/presentation/all_mothers/all_mothers_view.dart';
import 'package:fetosense_device_flutter/presentation/app_settings/app_setting.dart';
import 'package:fetosense_device_flutter/presentation/details/details_view.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/doppler_connection_view.dart';
import 'package:fetosense_device_flutter/presentation/home/home_view.dart';
import 'package:fetosense_device_flutter/presentation/login/login_view.dart';
import 'package:fetosense_device_flutter/presentation/mother_details/mother_details_view.dart';
import 'package:fetosense_device_flutter/presentation/notification/notification_view.dart';
import 'package:fetosense_device_flutter/presentation/register_mother/register_mother_view.dart';
import 'package:fetosense_device_flutter/presentation/splash/splash_screen.dart';
import 'package:fetosense_device_flutter/presentation/test/test_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockTest extends Mock implements Test {}

class MockMother extends Mock implements Mother {}

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

  testWidgets('Navigates to DopplerConnectionView',
      (WidgetTester tester) async {
    final router = appRouter;
    final mockTest = MockTest();
    final mockMother = MockMother();

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    router.go(AppRoutes.dopplerConnectionView,
        extra: {'test': mockTest, 'mother': mockMother, 'route': 'some_route'});
    await tester.pumpAndSettle();

    expect(find.byType(DopplerConnectionView), findsOneWidget);
  });

  testWidgets('Navigates to RegisterMotherView', (WidgetTester tester) async {
    final router = appRouter;
    final mockTest = MockTest();

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    router.go(AppRoutes.registerMother,
        extra: {'test': mockTest, 'route': 'some_route'});
    await tester.pumpAndSettle();

    expect(find.byType(RegisterMotherView), findsOneWidget);
  });

  testWidgets('Navigates to TestView', (WidgetTester tester) async {
    final router = appRouter;
    final mockTest = MockTest();
    final mockMother = MockMother();

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    router.go(AppRoutes.testView,
        extra: {'test': mockTest, 'mother': mockMother, 'route': 'some_route'});
    await tester.pumpAndSettle();

    expect(find.byType(TestView), findsOneWidget);
  });

  testWidgets('Navigates to DetailsView', (WidgetTester tester) async {
    final router = appRouter;
    final mockTest = MockTest();

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    router.go(AppRoutes.detailsView,
        extra: {'test': mockTest, 'from': 'some_route'});
    await tester.pumpAndSettle();

    expect(find.byType(DetailsView), findsOneWidget);
  });

  testWidgets('Navigates to AllMothersView', (WidgetTester tester) async {
    final router = appRouter;

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    router.go(AppRoutes.allMothersView, extra: true);
    await tester.pumpAndSettle();

    expect(find.byType(AllMothersView), findsOneWidget);
  });

  testWidgets('Navigates to NotificationView', (WidgetTester tester) async {
    final router = appRouter;

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    router.go(AppRoutes.notificationView);
    await tester.pumpAndSettle();

    expect(find.byType(NotificationView), findsOneWidget);
  });

  testWidgets('Navigates to AppSetting', (WidgetTester tester) async {
    final router = appRouter;

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    router.go(AppRoutes.appSettingsView);
    await tester.pumpAndSettle();

    expect(find.byType(AppSetting), findsOneWidget);
  });

  testWidgets('Navigates to MotherDetailsPage', (WidgetTester tester) async {
    final router = appRouter;
    final mockMother = MockMother();

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    router.go(AppRoutes.motherDetails, extra: mockMother);
    await tester.pumpAndSettle();

    expect(find.byType(MotherDetailsPage), findsOneWidget);
  });

  testWidgets('Navigates to AboutView', (WidgetTester tester) async {
    final router = appRouter;

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    router.go(AppRoutes.aboutView);
    await tester.pumpAndSettle();

    expect(find.byType(AboutView), findsOneWidget);
  });
}
