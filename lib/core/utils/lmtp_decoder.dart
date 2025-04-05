/*
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fetosense_device_flutter/core/fhr_byte_data_buffer.dart';
import 'package:fetosense_device_flutter/data/my_fhr_data.dart';

class LMTPDecoder {
  // Data streams for processing
  final StreamController<Uint8List> _inputStreamController = StreamController<Uint8List>.broadcast();
  final StreamController<BluetoothData> _decodedDataController = StreamController<BluetoothData>.broadcast();

  FhrByteDataBuffer? _byteDataBuffer;
  MyAudioTrack16Bit? _audioTrack;
  LMTPDecoderListener? _listener;
  bool _isWorking = false;
  bool _isRecording = false;
  bool _isSaving = false;

  int fmCounter = 0;
  int tocoCounter = 0;
  int docMark = 0;
  int monCount = 0;
  bool needLoopTranslate = false;
  bool monState = false;
  bool startCmdLost = false;
  bool stopCmdLost = false;
  int startCmdLostCount = 0;
  int stopCmdLostCount = 0;
  bool amplify = false;

  LMTPDecoder() {
    _byteDataBuffer = FhrByteDataBuffer();
    _audioTrack = MyAudioTrack16Bit();
  }

  bool prepare() {
    _byteDataBuffer = FhrByteDataBuffer();
    _audioTrack?.prepareAudioTrack();
    _isWorking = false;
    return true;
  }

  void startWork() {
    if (_isWorking) return;
    _isWorking = true;

    _inputStreamController.stream.listen((data) {
      _byteDataBuffer?.addDatas(data, 0, data.length);
    });

    Timer.periodic(Duration(milliseconds: 10), (timer) {
      if (!_isWorking) {
        timer.cancel();
        return;
      }
      if (_byteDataBuffer?.canRead() ?? false) {
        BluetoothData? data = _byteDataBuffer?.getBag();
        if (data != null) {
          dataAnalyze(data);
        }
      }
    });
  }

  void stopWork() {
    _isWorking = false;
    _inputStreamController.close();
    _decodedDataController.close();
    _audioTrack?.releaseAudioTrack();
  }

  void release() {
    stopWork();
    _byteDataBuffer = null;
    _listener = null;
  }

  bool isWorking() => _isWorking;

  void putData(Uint8List data) {
    if (_isWorking) {
      _inputStreamController.add(data);
    }
  }

  void dataAnalyze(BluetoothData data) {
    List<int> value;
    MyFhrData fhr;

    switch (data.dataType) {
      case 1:
        value = List.filled(200, 0);
        ADPCM.decodeAdpcm(value, 0, data.mValue, 3, 100, data.mValue[104], data.mValue[105], data.mValue[106]);
        decodeData(value);
        _listener?.fhrAudioChanged(value);
        break;

      case 2:
        fhr = FhrData();
        fhr.fhr1 = data.mValue[3] & 0xFF;
        fhr.fhr2 = data.mValue[4] & 0xFF;
        fhr.toco = data.mValue[5];
        fhr.afm = data.mValue[6];
        fhr.fhrSignal = data.mValue[7] & 0x03;
        fhr.afmFlag = (data.mValue[7] & 0x04) != 0 ? 1 : 0;
        fhr.devicePower = data.mValue[8] & 0x0F;
        fhr.isHaveFhr1 = (data.mValue[8] & 0x10) != 0 ? 1 : 0;
        fhr.isHaveFhr2 = (data.mValue[8] & 0x20) != 0 ? 1 : 0;
        fhr.isHaveToco = (data.mValue[8] & 0x40) != 0 ? 1 : 0;
        fhr.isHaveAfm = (data.mValue[8] & 0x80) != 0 ? 1 : 0;

        if (getFM()) fhr.fmFlag = 1;
        if (getToco()) fhr.tocoFlag = 1;
        if (getDocMark()) fhr.docFlag = 1;

        _listener?.fhrDataChanged(fhr);
        break;

      case 4:
        value = List.filled(400, 0);
        ADPCM.decodeAdpcmFor10Or12BitAnd100ms(value, 0, data.mValue, 3, 100, data.mValue[104], data.mValue[105], data.mValue[106], 10);
        decodeData(value);
        _listener?.fhrAudioChanged(value);
        break;

      case 5:
        clearStartOrStopCmd();
        needLoopTranslate = true;
        monCount = 0;
        break;

      case 6:
        clearStartOrStopCmd();
        needLoopTranslate = false;
        monCount = 0;
        break;
    }
  }

  void decodeData(List<int> decodeValue) {
    if (_audioTrack != null) {
      _audioTrack!.writeAudioTrack(decodeValue, 0, 200, false);
      if (decodeValue.length == 400) {
        _audioTrack!.writeAudioTrack(decodeValue, 200, 200, false);
      }
    }
  }

  bool getFM() => fmCounter-- > 0;
  void setFM() => fmCounter++;

  bool getDocMark() => docMark-- > 0;
  void setDocMark() => docMark++;

  bool getToco() => tocoCounter-- > 0;
  void setToco() => tocoCounter++;

  void sendStartOrStopCmd(bool param) {
    reSendStartOrStopCmd(param);
    if (!param) {
      monState = false;
      stopCmdLost = true;
      stopCmdLostCount = 0;
    } else {
      monState = true;
      startCmdLost = true;
      startCmdLostCount = 0;
    }
    monCount = 0;
  }

  void clearStartOrStopCmd() {
    stopCmdLost = false;
    stopCmdLostCount = 0;
    startCmdLost = false;
    startCmdLostCount = 0;
  }

  void reSendStartOrStopCmd(bool param) {
    _listener?.sendCommand(FhrCommandMaker.makeStartOrStopCmd(param, 0));
  }

  void setAmplify(bool value) {
    amplify = value;
  }

  String getVersion() {
    return "Luckcome mobile terminal protocol version \"3.4-20200310\"";
  }
}
*/
