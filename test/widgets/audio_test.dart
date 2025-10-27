import 'dart:async';

import 'package:fetosense_device_flutter/presentation/widgets/audio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';

// ---- MOCKS ----
class MockFlutterPcmSound extends Mock implements FlutterPcmSound {}

class MockPcmArrayInt16 extends Mock implements PcmArrayInt16 {
  static MockPcmArrayInt16 fromList(List<int> data) => MockPcmArrayInt16();
}

void main() {
  setUpAll(() {
    // Register fallback to avoid "missing stub" issues
    registerFallbackValue(MockPcmArrayInt16());
  });

  group('MyAudioTrack16Bit', () {
    late MyAudioTrack16Bit audioTrack;

    setUp(() {
      // Reset singleton instance for each test
      audioTrack = MyAudioTrack16Bit();
    });

    test('is a singleton', () {
      final anotherInstance = MyAudioTrack16Bit();
      expect(identical(audioTrack, anotherInstance), isTrue);
    });

    test('initialization sets correct defaults', () {
      expect(audioTrack.initialized, isTrue);
      expect(audioTrack.firstStart, isFalse);
      expect(audioTrack.packageWriteCount, equals(0));
      expect(audioTrack.packageReadCount, equals(0));
      expect(audioTrack.byteAvaliableToRead, equals(0));
      expect(audioTrack.bufSaveForRealTime.length, equals(8000));
      expect(audioTrack.bufForRealBudian.length, equals(320));
      expect(audioTrack.lastData, equals(0));
    });

    test('USHORT_MASK constant is correct', () {
      expect(MyAudioTrack16Bit.USHORT_MASK, equals((1 << 16) - 1));
    });

    test('playPCM does not throw when initialized', () async {
      final pcmData = [1, 2, 3];
      expect(() async => await audioTrack.playPCM(pcmData), returnsNormally);
    });

    test('releaseAudioTrack calls FlutterPcmSound.release', () async {
      // Spy on release call
      bool called = false;
      FlutterPcmSound.onFeedSamplesCallback = () {
        called = true;
      } as Function(int p1)?;
      await audioTrack.releaseAudioTrack();
      expect(called, isTrue);
    });

    test('playPCM prints when not initialized', () async {
      // Create a fresh instance with initialized=false
      final uninitAudio = MyAudioTrack16Bit();
      uninitAudio.initialized = false;

      // Capture console print
      final prints = <String>[];
      final spec = ZoneSpecification(print: (_, __, ___, String msg) {
        prints.add(msg);
      });

      await Zone.current.fork(specification: spec).run(() async {
        await uninitAudio.playPCM([1, 2]);
      });

      expect(prints.isNotEmpty, isTrue);
      expect(prints.first.contains('audio is playing?'), isTrue);
    });
  });
}
