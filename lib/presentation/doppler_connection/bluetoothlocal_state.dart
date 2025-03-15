part of 'bluetoothlocal_bloc.dart';

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
