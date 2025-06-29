import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/data/models/test_model.dart';
import 'package:fetosense_device_flutter/presentation/all_mothers/all_mothers_cubit.dart';
import 'package:fetosense_device_flutter/presentation/details/details_cubit.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/bluetoothlocal_bloc.dart';
import 'package:fetosense_device_flutter/presentation/login/login_cubit.dart';
import 'package:fetosense_device_flutter/presentation/mother_details/mother_details_cubit.dart';
import 'package:fetosense_device_flutter/presentation/register_mother/register_mother_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preferences/preference_service.dart';

/// The root widget of the Fetosense Device Flutter application.
///
/// `MyApp` sets up the application's theme, routing, and dependency injection.
/// It uses `MultiBlocProvider` to provide all required BLoC/Cubit instances
/// throughout the widget tree, enabling state management for authentication,
/// Bluetooth connection, mother registration, details, and test data.
///
/// Example usage:
/// ```dart
/// void main() {
///   runApp(const MyApp());
/// }
/// ```

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) async {
    ServiceLocator.setupLocator();
    ServiceLocator.sharedPrefsHelper;
    PrefService.init();
    runApp(const MyApp());
  });
}

final key = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginCubit(),
        ),
        BlocProvider(
          create: (context) =>
              BluetoothConnectionBloc(ServiceLocator.bluetoothServiceHelper),
        ),
        BlocProvider(
          create: (context) => AllMothersCubit(),
        ),
        BlocProvider(
          create: (context) => RegisterMotherCubit(),
        ),
         BlocProvider(
          create: (context) => MotherDetailsCubit(),
        ),
         BlocProvider(
          create: (context) => DetailsCubit(Test()),
        ),

      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: ColorManager.primaryButtonColor),
          useMaterial3: true,
        ),
      ),
    );
  }
}
