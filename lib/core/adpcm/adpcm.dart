import 'dart:ffi';
import 'dart:typed_data';
import 'dart:io';

import 'package:fetosense_device_flutter/core/fhr_byte_data_buffer.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

/// Native function type definitions
typedef DecodeAdpcmNative = Int32 Function(
    Pointer<Int16>,
    Int32,
    Pointer<Uint8>,
    Int32,
    Int32,
    Uint8,
    Uint8,
    Uint8
    );

typedef DecodeAdpcmDart = int Function(
    Pointer<Int16>,
    int,
    Pointer<Uint8>,
    int,
    int,
    int,
    int,
    int
    );

typedef DecodeAdpcm10Or12Native = Int32 Function(
    Pointer<Int16>,
    Int32,
    Pointer<Uint8>,
    Int32,
    Int32,
    Uint8,
    Uint8,
    Uint8,
    Uint8
    );

typedef DecodeAdpcm10Or12Dart = int Function(
    Pointer<Int16>,
    int,
    Pointer<Uint8>,
    int,
    int,
    int,
    int,
    int,
    int
    );

class ADPCM {
  late final DynamicLibrary _lib;

  late final DecodeAdpcmDart _decodeAdpcm;
  late final DecodeAdpcm10Or12Dart _decodeAdpcmFor10Or12BitAnd100ms;

  ADPCM() {
    // Load the native library
    _lib = Platform.isAndroid
        ? DynamicLibrary.open('libadpcm.so') // Android (shared object)
        : DynamicLibrary.process();          // iOS (linked automatically)

    _decodeAdpcm = _lib
        .lookupFunction<DecodeAdpcmNative, DecodeAdpcmDart>('decode_adpcm');

    _decodeAdpcmFor10Or12BitAnd100ms = _lib.lookupFunction<
        DecodeAdpcm10Or12Native,
        DecodeAdpcm10Or12Dart>('decode_adpcm_for_10_or_12_bit_and_100ms');
  }

  /// Decode ADPCM data
  List<int> decodeAdpcm(BluetoothData data) {
    final outputPtr = calloc<Int16>(200);
    final inputPtr = calloc<Uint8>(data.mValue.length);

    Uint8List inputBytes = inputPtr.asTypedList(data.mValue.length);
    inputBytes.setAll(0, data.mValue);  // Copy data correctly

    // debugPrint("Input length: ${inputBytes.length}");
    // debugPrint("Output buffer allocated: ${outputPtr.value.bitLength}");
    // debugPrint("Sample rate: 100");
    // debugPrint("Params: ${inputBytes[104]}, ${inputBytes[105]}, ${inputBytes[106]}");

    _decodeAdpcm(outputPtr, 0, inputPtr, 3, 100, inputBytes[104], inputBytes[105], inputBytes[106]);

    final result = outputPtr.asTypedList(200);
    // debugPrint("Output result : ${result.length}");

    calloc.free(outputPtr);
    calloc.free(inputPtr);

    return result;
  }

  /// Decode ADPCM data for 10 or 12-bit and 100ms
  List<int> decodeAdpcmFor10Or12BitAnd100ms(
      Int16List output,
      int var1,
      Uint8List input,
      int var3,
      int var4,
      int var5,
      int var6,
      int var7,
      int var8) {
    final outputPtr = calloc<Int16>(output.length);
    final inputPtr = calloc<Uint8>(input.length);

    for (int i = 0; i < input.length; i++) {
      inputPtr[i] = input[i];
    }

    _decodeAdpcmFor10Or12BitAnd100ms(
        outputPtr, var1, inputPtr, var3, var4, var5, var6, var7, var8);

    final result = List<int>.generate(output.length, (i) => outputPtr[i]);

    calloc.free(outputPtr);
    calloc.free(inputPtr);

    return result;
  }
}
