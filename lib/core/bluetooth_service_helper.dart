import 'dart:async';
import 'package:fetosense_device_flutter/core/adpcm/adpcm.dart';
import 'package:fetosense_device_flutter/core/audio.dart';
import 'package:fetosense_device_flutter/core/fhr_byte_data_buffer.dart';
import 'package:fetosense_device_flutter/data/models/my_fhr_data.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';

class BluetoothSerialService {
  static final BluetoothSerialService _instance =
  BluetoothSerialService._internal();

  factory BluetoothSerialService() => _instance;

  BluetoothSerialService._internal();

  BluetoothConnection? _connection;
  final FhrByteDataBuffer _buffer = FhrByteDataBuffer();
  Function(BluetoothData)? onDataReceived;
  final MyAudioTrack16Bit myAudioTrack16Bit = MyAudioTrack16Bit();

  final StreamController<MyFhrData> _dataStreamController = StreamController<MyFhrData>.broadcast();

  MyFhrData? lastFhr;

  Stream<MyFhrData> get dataStream => _dataStreamController.stream;

  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      print('Error getting paired devices: $e');
      return [];
    }
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      await disconnect();
      _connection = await BluetoothConnection.toAddress(device.address);
      print("Connected to ${device.name}");

      _connection!.input!.listen((data) {
        _onDataReceived(data);
      }, onDone: () {
        print("Bluetooth Connection Closed");
      });
      Timer.periodic(
        const Duration(milliseconds: 10),
            (timer) {
          _settingBuffer();
          if(timer.tick%100 == 0 && lastFhr!=null){
            _dataStreamController.add(lastFhr!);
          }
        },
      );
      return true;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  void _onDataReceived(Uint8List data) {
    if (data.isEmpty) {
      print("No data received from Bluetooth device.");
      return;
    }
    _buffer.addDatas(data, 0, data.length);
  }

  void _settingBuffer() {
    if (_buffer.canRead()) {
      BluetoothData? parsedData = _buffer.getBag();
      if (parsedData != null ) {
        // onDataReceived!(parsedData);
        final last = dataAnalyze(parsedData);
        if(last!=null && last is MyFhrData){
          // print("parsed data = ${lastFhr.toString()} : last $last");
          lastFhr = last;
        }
      } else {
        print("Parsed data is NULL. Possible issue in getBag()");
      }
    }
  }

  Future<void> disconnect() async {
    if (_connection != null) {
      _connection!.dispose();
      _connection = null;
    }
  }

  Future<bool> enableBluetooth() async {
    BluetoothState? state = await FlutterBluetoothSerial.instance.state;
    if (state == BluetoothState.STATE_OFF) {
      try {
        await FlutterBluetoothSerial.instance.requestEnable();
        return true;
      } catch (e) {
        print('Failed to enable Bluetooth: $e');
        return false;
      }
    }
    return true;
  }

  void dispose() {
    disconnect();
  }

  dynamic dataAnalyze(BluetoothData data) {
    MyFhrData? fhr;

    switch (data.dataType) {
      case 1:
        decodeData(ADPCM().decodeAdpcm(data));
        //decodeData(data.mValue.sublist(3, 103));
        break;

      case 2:
        fhr = MyFhrData();
        fhr.fhr1 = data.mValue[3] & 0xFF;
        fhr.fhr2 = data.mValue[4] & 0xFF;
        fhr.toco = data.mValue[5];
        fhr.afm = data.mValue[6];
        fhr.fhrSignal = (data.mValue[7] & 3);
        fhr.afmFlag = ((data.mValue[7] & 4) != 0 ? 1 : 0);
        fhr.devicePower = (data.mValue[8] & 15);
        fhr.isHaveFhr1 = ((data.mValue[8] & 16) != 0 ? 1 : 0);
        fhr.isHaveFhr2 = ((data.mValue[8] & 32) != 0 ? 1 : 0);
        fhr.isHaveToco = ((data.mValue[8] & 64) != 0 ? 1 : 0);
        fhr.isHaveAfm = ((data.mValue[8] & 128) != 0 ? 1 : 0);
        return fhr;

      case 3:
        int checkSum = 0;

        for (int index = 0; index < 11; ++index) {
          checkSum += data.mValue[index];
        }

        checkSum = checkSum & 0xFF;

        if (checkSum == data.mValue[11]) {
          int index = (0xFF & data.mValue[3]) + ((data.mValue[4] & 0xFF) << 8);

          // if (!monState) {
          //   reSendStartOrStopCmd(false);
          // } else {
          //   rePlyAckMonIndex(index);
          // }

          // if (monCount != index) {
          // monCount = index + 1;
          // } else {
          // monCount = index + 1;
          fhr = MyFhrData();
          fhr.fhr1 = data.mValue[5] & 0xFF;
          fhr.fhr2 = data.mValue[6] & 0xFF;
          fhr.toco = data.mValue[7];
          fhr.afm = data.mValue[8];
          fhr.fhrSignal = (data.mValue[9] & 3);
          fhr.afmFlag = ((data.mValue[9] & 4) != 0 ? 1 : 0);
          fhr.devicePower = (data.mValue[10] & 15);
          fhr.isHaveFhr1 = ((data.mValue[10] & 16) != 0 ? 1 : 0);
          fhr.isHaveFhr2 = ((data.mValue[10] & 32) != 0 ? 1 : 0);
          fhr.isHaveToco = ((data.mValue[10] & 64) != 0 ? 1 : 0);
          fhr.isHaveAfm = ((data.mValue[10] & 128) != 0 ? 1 : 0);

          _dataStreamController.add(fhr);

          // if (getFM()) {
          //   fhr.fmFlag = 1;
          // }
          //
          // if (getToco()) {
          //   fhr.tocoFlag = 1;
          // }
          //
          // if (getDocMark()) {
          //   fhr.docFlag = 1;
          // }
          //
          // if (mLMTPDecoderListener != null) {
          //   mLMTPDecoderListener.fhrDataChanged(fhr);
          // }
          // }
        }
        break;

      case 4:
        Int16List value = Int16List(200);
        ADPCM().decodeAdpcmFor10Or12BitAnd100ms(value, 0, data.mValue, 3, 100,
            data.mValue[104], data.mValue[105], data.mValue[106], 10);
        decodeData(value);
        // if (mLMTPDecoderListener != null) {
        //   mLMTPDecoderListener.fhrAudioChanged(value);
        // }
        break;

      case 5:
      // clearStartOrStopCmd();
      // needLoopTranslate = true;
      // monCount = 0;
        break;

      case 6:
        print("case 6");
        // clearStartOrStopCmd();
        // needLoopTranslate = false;
        // monCount = 0;
        break;
    }
  }

  void decodeData(List<int> decodeValue) {
    // myAudioTrack16Bit.prepareAudioTrack();
    int len = decodeValue.length;
    if (myAudioTrack16Bit.initialized) {
      myAudioTrack16Bit.playPCM(decodeValue);
    }
    /*if (len == 400) {
      myAudioTrack16Bit.writeAudioTrack(decodeValue, 200, 200, false);
    }*/
  }
}