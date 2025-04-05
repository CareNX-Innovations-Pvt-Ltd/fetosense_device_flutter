import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fetosense_device_flutter/core/utils/fhr_byte_data_buffer.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../../core/utils/bluetooth_service_helper.dart';

part 'bluetoothlocal_event.dart';

part 'bluetoothlocal_state.dart';

class BluetoothConnectionBloc
    extends Bloc<BluetoothConnectionEventLocal, BluetoothConnectionStateLocal> {
  final BluetoothSerialService _bluetoothService;

  BluetoothConnectionBloc(this._bluetoothService)
      : super(const BluetoothConnectionStateLocal()) {
    on<StartBluetoothScan>(_onStartBluetoothScan);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectDevice>(_onDisconnectDevice);
    on<DataReceived>(_onDataReceived);

    // Set up data listener from the Bluetooth service
    _bluetoothService.onDataReceived = (BluetoothData data) {
      // print("in BLoC?? -> ${data.mValue}");
      add(DataReceived(data));
    };
  }

  Future<void> _onStartBluetoothScan(StartBluetoothScan event,
      Emitter<BluetoothConnectionStateLocal> emit) async {
    try {
      emit(state.copyWith(isScanning: true));
      await _bluetoothService.enableBluetooth();
      List<BluetoothDevice> devices =
          await _bluetoothService.getPairedDevices();
      emit(state.copyWith(pairedDevices: devices, isScanning: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isScanning: false));
    }
  }

  Future<void> _onConnectToDevice(ConnectToDevice event,
      Emitter<BluetoothConnectionStateLocal> emit) async {
    try {
      emit(state.copyWith(isConnecting: true));
      bool success = await _bluetoothService.connect(event.device);

      if (success) {
        emit(
          state.copyWith(connectedDevice: event.device, isConnecting: false),
        );
      } else {
        emit(
          state.copyWith(error: 'Connection failed', isConnecting: false),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(error: e.toString(), isConnecting: false),
      );
    }
  }

  Future<void> _onDisconnectDevice(DisconnectDevice event,
      Emitter<BluetoothConnectionStateLocal> emit) async {
    await _bluetoothService.disconnect();
    emit(state.copyWith(connectedDevice: null));
  }

  void _onDataReceived(
      DataReceived event, Emitter<BluetoothConnectionStateLocal> emit) {
    final data = event.data;
    if(data.dataType == 2){
      // print("BLoC Received Data: Type = ${data.mValue}");
    }
  }

  @override
  Future<void> close() {
    _bluetoothService.dispose();
    return super.close();
  }
}
