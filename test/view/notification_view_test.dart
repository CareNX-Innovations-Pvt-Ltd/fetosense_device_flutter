import 'package:fetosense_device_flutter/presentation/notification/notification_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('NotificationView displays correct UI components',
          (WidgetTester tester) async {
        // Wrap the widget with MaterialApp and ScreenUtil
        await tester.pumpWidget(
          MaterialApp(
            home: ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (context, child) => const NotificationView(),
            ),
          ),
        );

        // Wait for widget tree to settle
        await tester.pumpAndSettle();

        // Verify AppBar back button exists
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Verify notification icon
        expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);

        // Verify texts
        expect(find.text('No notifications yet.'), findsOneWidget);
        expect(find.text("We'll keep you posted."), findsOneWidget);
      });

  testWidgets('Back button triggers pop', (WidgetTester tester) async {
    final mockRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const NotificationView(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: mockRouter,
      ),
    );

    await tester.pumpAndSettle();

    // Tap the back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(); // Allow navigation to process

    // No error thrown = pop is successful (in test context)
    expect(find.byType(NotificationView), findsNothing);
  });
}
