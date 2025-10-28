import 'package:bloc_test/bloc_test.dart';
import 'package:fetosense_device_flutter/core/utils/bluetooth_service_helper.dart';
import 'package:fetosense_device_flutter/core/utils/fhr_byte_data_buffer.dart';
import 'package:fetosense_device_flutter/presentation/doppler_connection/bluetoothlocal_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBluetoothSerialService extends Mock implements BluetoothSerialService {}
class FakeBluetoothDevice extends Fake implements BluetoothDevice {}
class FakeBluetoothData extends Fake implements BluetoothData {}

void main() {
  late MockBluetoothSerialService mockService;
  late BluetoothConnectionBloc bloc;

  setUpAll(() {
    registerFallbackValue(FakeBluetoothDevice());
    registerFallbackValue(FakeBluetoothData());
  });

  setUp(() {
    mockService = MockBluetoothSerialService();

    // Setup default behavior
    when(() => mockService.enableBluetooth()).thenAnswer((_) async {
      return true;
    });
    when(() => mockService.getPairedDevices())
        .thenAnswer((_) async => [const BluetoothDevice(name: 'Device1', address: '00:11')]);
    when(() => mockService.connect(any())).thenAnswer((_) async => true);
    when(() => mockService.disconnect()).thenAnswer((_) async {});
    when(() => mockService.dispose()).thenReturn(null);

    bloc = BluetoothConnectionBloc(mockService);
  });

  tearDown(() {
    bloc.close();
  });

  blocTest<BluetoothConnectionBloc, BluetoothConnectionStateLocal>(
    'emits [isScanning: true, pairedDevices, isScanning: false] when StartBluetoothScan succeeds',
    build: () => bloc,
    act: (bloc) => bloc.add(StartBluetoothScan()),
    expect: () => [
      const BluetoothConnectionStateLocal(isScanning: true),
      const BluetoothConnectionStateLocal(
        isScanning: false,
        pairedDevices: [BluetoothDevice(name: 'Device1', address: '00:11')],
      ),
    ],
    verify: (_) {
      verify(() => mockService.enableBluetooth()).called(1);
      verify(() => mockService.getPairedDevices()).called(1);
    },
  );

  blocTest<BluetoothConnectionBloc, BluetoothConnectionStateLocal>(
    'emits error when StartBluetoothScan throws',
    build: () {
      when(() => mockService.enableBluetooth()).thenThrow(Exception('Failed'));
      return bloc;
    },
    act: (bloc) => bloc.add(StartBluetoothScan()),
    expect: () => [
      const BluetoothConnectionStateLocal(isScanning: true),
      const BluetoothConnectionStateLocal(isScanning: false, error: 'Exception: Failed'),
    ],
  );

  blocTest<BluetoothConnectionBloc, BluetoothConnectionStateLocal>(
    'emits [isConnecting, connectedDevice] when ConnectToDevice succeeds',
    build: () => bloc,
    act: (bloc) => bloc.add(const ConnectToDevice(BluetoothDevice(name: 'Device1', address: '00:11'))),
    expect: () => [
      const BluetoothConnectionStateLocal(isConnecting: true),
      const BluetoothConnectionStateLocal(
        isConnecting: false,
        connectedDevice: BluetoothDevice(name: 'Device1', address: '00:11'),
      ),
    ],
  );

  blocTest<BluetoothConnectionBloc, BluetoothConnectionStateLocal>(
    'emits error when ConnectToDevice fails',
    build: () {
      when(() => mockService.connect(any())).thenAnswer((_) async => false);
      return bloc;
    },
    act: (bloc) => bloc.add(const ConnectToDevice(BluetoothDevice(name: 'Device1', address: '00:11'))),
    expect: () => [
      const BluetoothConnectionStateLocal(isConnecting: true),
      const BluetoothConnectionStateLocal(isConnecting: false, error: 'Connection failed'),
    ],
  );

  blocTest<BluetoothConnectionBloc, BluetoothConnectionStateLocal>(
    'disconnects device correctly',
    build: () => bloc,
    seed: () => const BluetoothConnectionStateLocal(
        connectedDevice: BluetoothDevice(name: 'Device1', address: '00:11')),
    act: (bloc) => bloc.add(DisconnectDevice()),
    expect: () => [
      const BluetoothConnectionStateLocal(connectedDevice: null),
    ],
    verify: (_) {
      verify(() => mockService.disconnect()).called(1);
    },
  );

  test('DataReceived event triggers _onDataReceived', () {
    final data = BluetoothData();
    bloc.add(DataReceived(data));
    // Since _onDataReceived does not modify state, we just ensure no error occurs
  });

  test('Bloc disposes Bluetooth service on close', () async {
    await bloc.close();
    verify(() => mockService.dispose()).called(1);
  });

  test('Bluetooth service listener adds DataReceived', () async {
    final data = BluetoothData();

    // Manually trigger onDataReceived callback
    mockService.onDataReceived!(data);

    // Wait for bloc to process event
    await Future.delayed(Duration.zero);

    // The state won't change for dataType 2, but the event is handled
  });
}
