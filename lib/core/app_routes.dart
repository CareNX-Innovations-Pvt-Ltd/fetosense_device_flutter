import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/main.dart';
import 'package:fetosense_device_flutter/presentation/details/details_view.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/doppler_connection_view.dart';
import 'package:fetosense_device_flutter/presentation/home/home_view.dart';
import 'package:fetosense_device_flutter/presentation/login/login_view.dart';
import 'package:fetosense_device_flutter/presentation/register_mother/register_mother_view.dart';
import 'package:fetosense_device_flutter/presentation/splash/splash_screen.dart';
import 'package:fetosense_device_flutter/presentation/test/test_view.dart';
import 'package:go_router/go_router.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const speakerConnection = '/speaker_connection';
  static const dopplerConnectionView = '/doppler';
  static const registerMother = '/register_mother';
  static const testView = '/test';
  static const detailsView = '/details_view';
}

final GoRouter appRouter = GoRouter(
  navigatorKey: key,
  routes: [
    GoRoute(
      name: '/',
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: '/login',
      path: AppRoutes.login,
      builder: (context, state) => LoginView(),
    ),
    GoRoute(
      name: '/home',
      path: AppRoutes.home,
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      name: '/doppler',
      path: AppRoutes.dopplerConnectionView,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        var test = extra?['test'] as Test;
        var previousRoute = extra?['route'];
        return DopplerConnectionView(
          previousRoute: previousRoute,
          test: test,
        );
      },
    ),
    GoRoute(
      name: '/register_mother',
      path: AppRoutes.registerMother,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        var test = extra?['test'] as Test;
        var previousRoute = extra?['route'];
        return RegisterMotherView(
          test: test,
          previousRoute: previousRoute,
        );
      },
    ),
    GoRoute(
      name: '/test',
      path: AppRoutes.testView,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        var test = extra?['test'] as Test;
        var previousRoute = extra?['route'];
        return TestView(
          test: test,
          previousRoute: previousRoute,
        );
      },
    ),
    GoRoute(
      name: '/details_view',
      path: AppRoutes.detailsView,
      builder: (context, state) {
        var test = state.extra as Test;
        return DetailsView(
          test: test,
        );
      },
    ),
  ],
);
