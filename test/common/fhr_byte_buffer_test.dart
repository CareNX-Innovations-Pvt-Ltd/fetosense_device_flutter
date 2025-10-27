import 'dart:typed_data';
import 'package:fetosense_device_flutter/core/utils/fhr_byte_data_buffer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FhrByteDataBuffer buffer;

  setUp(() {
    buffer = FhrByteDataBuffer();
  });

  test('Buffer starts empty', () {
    expect(buffer.canRead(), false);
    expect(buffer.getBag(), null);
  });

  test('can add and read a valid packet type 1/3', () {
    Uint8List packet = Uint8List(107);
    packet[0] = 85;
    packet[1] = 170;
    packet[2] = 1;
    for (int i = 3; i < 107; i++) packet[i] = i;

    buffer.addDatas(packet, 0, 107);
    expect(buffer.canRead(), true);

    final data = buffer.getBag();
    expect(data, isNotNull);
    expect(data!.dataType, 2);
    expect(data.mValue[0], 85);
    expect(data.mValue[9], 12);
  });

  test('Invalid packet start is skipped', () {
    buffer.addData(0);
    buffer.addData(1);
    buffer.addData(2);

    expect(buffer.getBag(), null);
  });

  test('Handles packet split across buffer boundary', () {
    Uint8List filler = Uint8List(FhrByteDataBuffer.bufferLength - 50);
    buffer.addDatas(filler, 0, filler.length);

    Uint8List packet = Uint8List(107);
    packet[0] = 85;
    packet[1] = 170;
    packet[2] = 8;
    for (int i = 3; i < 107; i++) packet[i] = i;

    buffer.addDatas(packet, 0, 107);

    final data = buffer.getBag();
    expect(data, isNotNull);
    expect(data!.dataType, 1);
  });

  test('Buffer overflow keeps newest data accessible', () {
    Uint8List data = Uint8List(FhrByteDataBuffer.bufferLength + 10);
    for (int i = 0; i < data.length; i++) {
      buffer.addData(i);
    }

    expect(buffer.canRead(), false);
    expect(buffer.getBag(), null);
  });

  test('clean resets buffer state', () {
    buffer.addData(1);
    buffer.clean();
    expect(buffer.canRead(), false);
    expect(buffer.getBag(), null);
  });
}
