part of 'bluetoothlocal_bloc.dart';

/// Represents the state of the Bluetooth connection for local Doppler devices.
///
/// `BluetoothConnectionStateLocal` holds all relevant data for managing and displaying
/// Bluetooth connection status, including the list of paired devices, the currently
/// connected device, received data, scanning/connecting flags, and error messages.
/// This state is used by [BluetoothConnectionBloc] to emit updates to the UI.
///
/// Use [copyWith] to create updated copies of the state with modified fields.
///
/// Example usage:
/// ```dart
/// final newState = state.copyWith(isScanning: true);
/// ```

class BluetoothConnectionStateLocal extends Equatable {
  final List<BluetoothDevice> pairedDevices;
  final BluetoothDevice? connectedDevice;
  final List<BluetoothData> receivedData;
  final bool isScanning;
  final bool isConnecting;
  final String? error;

  const BluetoothConnectionStateLocal({
    this.pairedDevices = const [],
    this.connectedDevice,
    this.receivedData = const [],
    this.isScanning = false,
    this.isConnecting = false,
    this.error,
  });

  BluetoothConnectionStateLocal copyWith({
    List<BluetoothDevice>? pairedDevices,
    BluetoothDevice? connectedDevice,
    List<BluetoothData>? receivedData,
    bool? isScanning,
    bool? isConnecting,
    String? error,
  }) {
    return BluetoothConnectionStateLocal(
      pairedDevices: pairedDevices ?? this.pairedDevices,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      receivedData: receivedData ?? this.receivedData,
      isScanning: isScanning ?? this.isScanning,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    pairedDevices,
    connectedDevice,
    receivedData,
    isScanning,
    isConnecting,
    error
  ];
}
