import 'package:fetosense_device_flutter/main.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/doppler_connection_view.dart';
import 'package:fetosense_device_flutter/presentation/home/home_view.dart';
import 'package:fetosense_device_flutter/presentation/login/login_view.dart';
import 'package:fetosense_device_flutter/presentation/register_mother/register_mother_view.dart';
import 'package:fetosense_device_flutter/presentation/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const speakerConnection = '/speaker_connection';
  static const dopplerConnectionView = '/doppler';
  static const registerMother = '/register_mother';
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
        // locator<BluetoothServiceHelper>();
        // locator<SharedPrefsHelper>().init();
        return const DopplerConnectionView();
      },
    ),
    // GoRoute(
    //   name: '/speaker_connection',
    //   path: AppRoutes.speakerConnection,
    //   builder: (context, state) => const SpeakerConnectionView(),
    // ),
    GoRoute(
      name: '/register_mother',
      path: AppRoutes.registerMother,
      builder: (context, state) => const RegisterMotherView(),
    ),
  ],
);
