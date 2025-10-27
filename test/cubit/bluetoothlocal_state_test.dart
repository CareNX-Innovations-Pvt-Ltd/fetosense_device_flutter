import 'package:fetosense_device_flutter/core/utils/fhr_byte_data_buffer.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/bluetoothlocal_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BluetoothConnectionStateLocal', () {
    test('default constructor sets default values', () {
      const state = BluetoothConnectionStateLocal();

      expect(state.pairedDevices, []);
      expect(state.connectedDevice, null);
      expect(state.receivedData, []);
      expect(state.isScanning, false);
      expect(state.isConnecting, false);
      expect(state.error, null);
    });

    test('copyWith updates values correctly', () {
      const device = BluetoothDevice(name: 'Device1', address: '00:11');
      final data = BluetoothData();

      final state = const BluetoothConnectionStateLocal().copyWith(
        pairedDevices: [device],
        connectedDevice: device,
        receivedData: [data],
        isScanning: true,
        isConnecting: true,
        error: 'Some error',
      );

      expect(state.pairedDevices, [device]);
      expect(state.connectedDevice, device);
      expect(state.receivedData, [data]);
      expect(state.isScanning, true);
      expect(state.isConnecting, true);
      expect(state.error, 'Some error');
    });

    test('copyWith retains existing values if null passed', () {
      const device = BluetoothDevice(name: 'Device1', address: '00:11');
      final data = BluetoothData();

      final original = BluetoothConnectionStateLocal(
        pairedDevices: [device],
        connectedDevice: device,
        receivedData: [data],
        isScanning: true,
        isConnecting: true,
        error: 'Error',
      );

      final copy = original.copyWith();

      expect(copy.pairedDevices, original.pairedDevices);
      expect(copy.connectedDevice, original.connectedDevice);
      expect(copy.receivedData, original.receivedData);
      expect(copy.isScanning, original.isScanning);
      expect(copy.isConnecting, original.isConnecting);
      expect(copy.error, original.error);
    });

    test('props includes all fields for Equatable', () {
      const device = BluetoothDevice(name: 'Device1', address: '00:11');
      final data = BluetoothData();

      final state1 = BluetoothConnectionStateLocal(
        pairedDevices: [device],
        connectedDevice: device,
        receivedData: [data],
        isScanning: true,
        isConnecting: true,
        error: 'Error',
      );

      final state2 = BluetoothConnectionStateLocal(
        pairedDevices: [device],
        connectedDevice: device,
        receivedData: [data],
        isScanning: true,
        isConnecting: true,
        error: 'Error',
      );

      expect(state1, state2); // Equatable comparison
    });
  });
}
