import 'package:appwrite/appwrite.dart';
import 'package:fetosense_device_flutter/presentation/widgets/audio.dart';
import 'package:fetosense_device_flutter/core/utils/bluetooth_service_helper.dart';
import 'package:fetosense_device_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_device_flutter/core/utils/preferences.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/bluetoothlocal_bloc.dart';
import 'package:get_it/get_it.dart';

/// A service locator for dependency injection using the [GetIt] package.
///
/// This class registers and provides singleton and factory instances of
/// commonly used services and BLoCs throughout the application, such as:
/// - [BluetoothSerialService] for Bluetooth communication
/// - [PreferenceHelper] for shared preferences management
/// - [BluetoothConnectionBloc] for managing Bluetooth connection state
/// - [MyAudioTrack16Bit] for audio playback
/// - [AppwriteService] for Appwrite backend communication
///
/// Call [setupLocator] at app startup to register all dependencies.
/// Use the provided getters to access registered instances.
///
/// Example usage:
/// ```dart
/// ServiceLocator.setupLocator();
/// final bluetoothService = ServiceLocator.bluetoothServiceHelper;
/// ```

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
    _getIt.registerLazySingleton(() => Databases(
          _getIt<AppwriteService>().client,
        ));
  }

  static BluetoothConnectionBloc get bluetoothBloc =>
      _getIt<BluetoothConnectionBloc>();

  static Future<void> get sharedPrefsHelper => PreferenceHelper.init();

  static BluetoothSerialService get bluetoothServiceHelper =>
      _getIt<BluetoothSerialService>();

  static MyAudioTrack16Bit get myAudioTrack => _getIt<MyAudioTrack16Bit>();

  static AppwriteService get appwriteService => _getIt<AppwriteService>();

  static PreferenceHelper get preferenceHelper => _getIt<PreferenceHelper>();
}
