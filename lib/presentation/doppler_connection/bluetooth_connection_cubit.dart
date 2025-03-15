import 'package:bloc/bloc.dart';
import 'package:fetosense_device_flutter/core/fhr_byte_data_buffer.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../core/bluetooth_service_helper.dart';
import 'bluetooth_connection_state.dart';

class BluetoothConnectionCubit extends Cubit<BluetoothConnectionState> {
  final BluetoothSerialService _bluetoothService;

  BluetoothConnectionCubit(this._bluetoothService)
      : super(BluetoothConnectionState()) {
    _setupListeners();
  }

  void _setupListeners() {
    _bluetoothService.onDataReceived = (BluetoothData data) {
      print("Cubit Received Data: Type = ${data.dataType}");
      emit(state.copyWith(receivedData: [data, ...state.receivedData]));
    };
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    emit(state.copyWith(isLoading: true));

    try {
      final success = await _bluetoothService.connect(device);

      if (!success) {
        emit(state.copyWith(error: 'Connection failed', isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void disconnectDevice() async {
    await _bluetoothService.disconnect();
    emit(state.copyWith(receivedData: []));
  }
}
