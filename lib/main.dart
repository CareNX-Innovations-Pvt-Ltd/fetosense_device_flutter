import 'package:fetosense_device_flutter/core/utils/color_manager.dart';
import 'package:fetosense_device_flutter/core/constants/app_routes.dart';
import 'package:fetosense_device_flutter/core/network/dependency_injection.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/bluetoothlocal_bloc.dart';
import 'package:fetosense_device_flutter/presentation/login/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preferences/preference_service.dart';

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
          create: (context) => BluetoothConnectionBloc(ServiceLocator.bluetoothServiceHelper),
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
