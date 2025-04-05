import 'package:fetosense_device_flutter/core/utils/fhr_byte_data_buffer.dart';

class BluetoothConnectionState {
  final List<BluetoothData> receivedData;
  final bool isLoading;
  final String? error;

  BluetoothConnectionState({
    this.receivedData = const [],
    this.isLoading = false,
    this.error,
  });

  BluetoothConnectionState copyWith({
    List<BluetoothData>? receivedData,
    bool? isLoading,
    String? error,
  }) {
    return BluetoothConnectionState(
      receivedData: receivedData ?? this.receivedData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
