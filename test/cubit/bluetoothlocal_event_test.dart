import 'package:fetosense_device_flutter/core/utils/fhr_byte_data_buffer.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/bluetoothlocal_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('StartBluetoothScan props are empty', () {
    final event = StartBluetoothScan();
    expect(event.props, []);
  });

  test('ConnectToDevice props contain device', () {
    const device = BluetoothDevice(name: 'Device1', address: '00:11');
    const event = ConnectToDevice(device);
    expect(event.props, [device]);
  });

  test('DisconnectDevice props are empty', () {
    final event = DisconnectDevice();
    expect(event.props, []);
  });

  test('DataReceived props contain data', () {
    final data = BluetoothData();
    final event = DataReceived(data);
    expect(event.props, [data]);
  });

  test('Equatable comparison works', () {
    const device1 = BluetoothDevice(name: 'Device1', address: '00:11');
    const device2 = BluetoothDevice(name: 'Device1', address: '00:11');

    expect(ConnectToDevice(device1), ConnectToDevice(device2));
  });
}
