import 'dart:ffi';
import 'dart:typed_data';
import 'package:fetosense_device_flutter/core/adpcm/adpcm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ffi/ffi.dart';
import 'package:fetosense_device_flutter/core/utils/fhr_byte_data_buffer.dart';

void main() {
  group('ADPCM', () {
    test('decodeAdpcm returns mock decoded data', () {
      final mockDecoder = ADPCM(
        overrideDecodeAdpcm: (
            Pointer<Int16> outputPtr,
            int a,
            Pointer<Uint8> inputPtr,
            int b,
            int c,
            int d,
            int e,
            int f,
            ) {
          for (int i = 0; i < 200; i++) {
            outputPtr[i] = i;
          }
          return 0;
        },
        overrideDecodeAdpcm10Or12: (
            Pointer<Int16> outputPtr,
            int a,
            Pointer<Uint8> inputPtr,
            int b,
            int c,
            int d,
            int e,
            int f,
            int g,
            ) {
          for (int i = 0; i < 100; i++) {
            outputPtr[i] = i + 100;
          }
          return 0;
        },
      );

      final testData = List<int>.generate(110, (i) => i); // length > 106
      testData[104] = 1;
      testData[105] = 2;
      testData[106] = 3;

      final result = mockDecoder.decodeAdpcm(BluetoothData());
      expect(result.length, 200);
      expect(result.first, 0);
      expect(result.last, 199);
    });

    test('decodeAdpcmFor10Or12BitAnd100ms returns mock decoded data', () {
      final mockDecoder = ADPCM(
        overrideDecodeAdpcm: (_, __, ___, ____, _____, ______, _______, ________) => 0,
        overrideDecodeAdpcm10Or12: (
            Pointer<Int16> outputPtr,
            int a,
            Pointer<Uint8> inputPtr,
            int b,
            int c,
            int d,
            int e,
            int f,
            int g,
            ) {
          for (int i = 0; i < 50; i++) {
            outputPtr[i] = i + 10;
          }
          return 0;
        },
      );

      final input = Uint8List.fromList(List.generate(100, (i) => i));
      final output = Int16List(50);

      final result = mockDecoder.decodeAdpcmFor10Or12BitAnd100ms(
          output,
          1, input, 3, 4, 5, 6, 7, 8);

      expect(result.length, 50);
      expect(result[0], 10);
      expect(result[49], 59);
    });
  });
}
