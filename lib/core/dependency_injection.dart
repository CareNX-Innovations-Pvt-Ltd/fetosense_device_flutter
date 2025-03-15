import 'package:fetosense_device_flutter/core/audio.dart';
import 'package:fetosense_device_flutter/core/bluetooth_service_helper.dart';
import 'package:fetosense_device_flutter/core/shared_prefs_helper.dart';
import 'package:get_it/get_it.dart';

import '../presentation/doppler_connection/bluetoothlocal_bloc.dart';

class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static void setupLocator() {
    _getIt.registerLazySingleton<BluetoothSerialService>(
      () => BluetoothSerialService(),
    );

    _getIt.registerLazySingleton<SharedPrefsHelper>(
      () => SharedPrefsHelper(),
    );

    _getIt.registerFactory<BluetoothConnectionBloc>(
      () => BluetoothConnectionBloc(
        _getIt<BluetoothSerialService>(),
      ),
    );
    _getIt.registerLazySingleton<MyAudioTrack16Bit>(
      () => MyAudioTrack16Bit(),
    );
  }

  static BluetoothConnectionBloc get bluetoothBloc =>
      _getIt<BluetoothConnectionBloc>();

  static Future<void> get sharedPrefsHelper =>
      _getIt<SharedPrefsHelper>().init();

  static BluetoothSerialService get bluetoothServiceHelper =>
      BluetoothSerialService();

  static MyAudioTrack16Bit get myAudioTrack => MyAudioTrack16Bit();
}
