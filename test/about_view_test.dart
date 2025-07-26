import 'package:fetosense_device_flutter/presentation/about/about_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('AboutView renders correctly and contains expected widgets', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/about',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('Home'))),
        GoRoute(path: '/about', builder: (context, state) => const AboutView()),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.text('Website'), findsOneWidget);
    expect(find.text('Contact Us'), findsOneWidget);
  });

  testWidgets('Tapping back button pops the navigation stack', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/about'),
                child: const Text('Go to About'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutView(),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // Verify initial screen
    expect(find.text('Go to About'), findsOneWidget);

    // Navigate to About
    await tester.tap(find.text('Go to About'));
    await tester.pumpAndSettle();

    // Now on About screen
    expect(find.text('About'), findsOneWidget);

    // Tap the back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Should be back on home screen
    expect(find.text('Go to About'), findsOneWidget);
  });
}
