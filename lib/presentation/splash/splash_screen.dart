import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// A stateful widget that displays the splash screen and handles initial navigation.
///
/// `SplashScreen` shows a splash image for 3 seconds, then checks the user's auto-login
/// preference using [PreferenceHelper]. Based on this, it navigates to either the home
/// screen or the login screen using [GoRouter].
///
/// Example usage:
/// ```dart
/// MaterialApp(
///   home: SplashScreen(),
/// );
/// ```

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final prefs = GetIt.I<PreferenceHelper>();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
       if(prefs.getAutoLogin()) {
          context.go(AppRoutes.home);
        } else {
         context.go(AppRoutes.login);
       }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorManager.white,
        body: Center(
          child: Image.asset('assets/splash.jpg', fit: BoxFit.fill,),
        ),
      ),
    );
  }
}
