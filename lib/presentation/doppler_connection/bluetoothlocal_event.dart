part of 'bluetoothlocal_bloc.dart';

/// Abstract base class for all Bluetooth connection events in the local Doppler context.
///
/// `BluetoothConnectionEventLocal` defines the contract for events handled by
/// [BluetoothConnectionBloc], such as starting a scan, connecting/disconnecting
/// devices, and receiving data. Extend this class to implement specific event types.
///
/// All subclasses must implement [Equatable] for value comparison.

abstract class BluetoothConnectionEventLocal extends Equatable {
  const BluetoothConnectionEventLocal();

  @override
  List<Object> get props => [];
}

class StartBluetoothScan extends BluetoothConnectionEventLocal {}

class ConnectToDevice extends BluetoothConnectionEventLocal {
  final BluetoothDevice device;

  const ConnectToDevice(this.device);

  @override
  List<Object> get props => [device];
}

class DisconnectDevice extends BluetoothConnectionEventLocal {}

class DataReceived extends BluetoothConnectionEventLocal {
  final BluetoothData data;

  const DataReceived(this.data);

  @override
  List<Object> get props => [data];
}


// class SendBluetoothData extends BluetoothConnectionEventLocal {
//   final String data;
//
//   const SendBluetoothData(this.data);
//
//   @override
//   List<Object> get props => [data];
// }