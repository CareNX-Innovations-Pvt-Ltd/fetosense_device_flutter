import 'dart:typed_data';

class FhrByteDataBuffer {
  static const int bufferLength = 4096;
  final Uint8List _buffer = Uint8List(bufferLength);

  int _inIndex = 0;
  int _outIndex = 0;
  int _count = 0;

  FhrByteDataBuffer();

  BluetoothData? getBag() {
    // print("GET: In index $_inIndex | Out index $_outIndex | Count $_count");

    if (_count < 107) {
      print("Not enough data in buffer to process a complete packet.");
      return null;
    }

    BluetoothData? data;

    while (_count >= 107) {
      // Validate the packet start sequence
      if (_testBuffer(_outIndex) == 85 && _testBuffer(_outIndex + 1) == 170) {
        data = BluetoothData();
        int dataType = _testBuffer(_outIndex + 2);

        switch (dataType) {
          case 1:
          case 3:
            data.dataType = 2;
            _extractData(data, 10);
            break;
          case 8:
          case 9:
          case 25:
            data.dataType = (dataType == 25) ? 4 : 1;
            _extractData(data, 107);
            break;
          case 19:
            data.dataType = 3;
            _extractData(data, 12);
            break;
          case 48:
          case 49:
            data.dataType = (dataType == 48) ? 5 : 6;
            _extractData(data, 8);
            break;
          default:
            print("Unknown data type: $dataType. Skipping 3 bytes.");
            _advanceBuffer(3);
        }

        // print("Packet successfully extracted: Type = ${data.dataType}");
        return data;
      } else {
        print("Invalid packet start sequence. Advancing buffer...");
        _advanceBuffer(1);
      }
    }

    print("No valid packet found.");
    return null;
  }

  void _extractData(BluetoothData data, int length) {
    int availableBytes = bufferLength - _outIndex;

    if (availableBytes >= length) {
      // Full packet fits within buffer boundary
      data.mValue
          .setRange(0, length, _buffer.sublist(_outIndex, _outIndex + length));
      _advanceBuffer(length);
    } else {
      // Packet is split across buffer boundary
      data.mValue.setRange(
          0, availableBytes, _buffer.sublist(_outIndex, bufferLength));
      data.mValue.setRange(
          availableBytes, length, _buffer.sublist(0, length - availableBytes));
      _advanceBuffer(length);
    }
  }

  void _advanceBuffer(int steps) {
    _outIndex = (_outIndex + steps) % bufferLength;
    _count -= steps;
  }

  int _testBuffer(int index) => _buffer[index % bufferLength];

  void addData(int data) {
    _buffer[_inIndex] = data;
    _inIndex = (_inIndex + 1) % bufferLength;

    if (_count < bufferLength) {
      _count++;
    } else {
      _advanceBuffer(1); // Overwrite oldest data on overflow
    }
  }

  void addDatas(Uint8List data, int startIndex, int endIndex) {
    int length = endIndex - startIndex;

    for (int i = 0; i < length; i++) {
      addData(data[startIndex + i]);
    }
    // print("ADD: In index $_inIndex | Out index $_outIndex | Count $_count");
  }

  void clean() {
    _inIndex = 0;
    _outIndex = 0;
    _count = 0;
  }

  bool canRead() => _count >= 107;
}

class BluetoothData {
  int dataType = 0;
  Uint8List mValue = Uint8List(107);
}
