import 'package:fetosense_device_flutter/presentation/widgets/audio.dart';
import 'package:fetosense_device_flutter/core/utils/bluetooth_service_helper.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/bluetoothlocal_bloc.dart';
import 'package:get_it/get_it.dart';


class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static void setupLocator() {
    _getIt.registerLazySingleton<BluetoothSerialService>(
      () => BluetoothSerialService(),
    );

    _getIt.registerLazySingleton<PreferenceHelper>(
      () => PreferenceHelper(),
    );

    _getIt.registerFactory<BluetoothConnectionBloc>(
      () => BluetoothConnectionBloc(
        _getIt<BluetoothSerialService>(),
      ),
    );
    _getIt.registerLazySingleton<MyAudioTrack16Bit>(
      () => MyAudioTrack16Bit(),
    );
    _getIt.registerLazySingleton<AppwriteService>(
      () => AppwriteService(),
    );
  }

  static BluetoothConnectionBloc get bluetoothBloc =>
      _getIt<BluetoothConnectionBloc>();

  static Future<void> get sharedPrefsHelper =>
      PreferenceHelper.init();

  static BluetoothSerialService get bluetoothServiceHelper =>
      BluetoothSerialService();

  static MyAudioTrack16Bit get myAudioTrack => MyAudioTrack16Bit();

  static AppwriteService get appwriteService => AppwriteService();
}
