import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_device_flutter/core/utils/fhr_byte_data_buffer.dart';

void main() {
  group('FhrByteDataBuffer', () {
    late FhrByteDataBuffer buffer;

    setUp(() {
      buffer = FhrByteDataBuffer();
    });

    test('should add single data correctly', () {
      buffer.addData(85);
      buffer.addData(170);

      expect(buffer.canRead(), false);
    });

    test('should add multiple data correctly', () {
      final data = Uint8List.fromList(List<int>.generate(107, (index) => index));
      buffer.addDatas(data, 0, data.length);

      expect(buffer.canRead(), true);
    });

    test('should extract valid packet correctly', () {
      final data = Uint8List.fromList([85, 170, 1, ...List<int>.generate(104, (index) => index)]);
      buffer.addDatas(data, 0, data.length);

      final packet = buffer.getBag();
      expect(packet, isNotNull);
      expect(packet!.dataType, 2);
      expect(packet.mValue.length, 107);
    });

    test('should handle invalid packet start sequence', () {
      final data = Uint8List.fromList([0, 0, 0, 85, 170, 1, ...List<int>.generate(104, (index) => index)]);
      buffer.addDatas(data, 0, data.length);

      final packet = buffer.getBag();
      expect(packet, isNotNull);
      expect(packet!.dataType, 2);
    });

    test('should clean buffer correctly', () {
      final data = Uint8List.fromList(List<int>.generate(107, (index) => index));
      buffer.addDatas(data, 0, data.length);

      buffer.clean();
      expect(buffer.canRead(), false);
    });

    test('should handle buffer overflow correctly', () {
      final data = Uint8List.fromList(List<int>.generate(4096, (index) => index));
      buffer.addDatas(data, 0, data.length);

      expect(buffer.canRead(), true);
    });
  });
}