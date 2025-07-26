import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fetosense_device_flutter/core/utils/color_manager.dart';

void main() {
  group('ColorManager', () {
    test('should have correct white color value', () {
      expect(ColorManager.white, const Color(0xffffffff));
    });

    test('should have correct black color value', () {
      expect(ColorManager.black, const Color(0xff000000));
    });

    test('should have correct primaryColor value', () {
      expect(ColorManager.primaryColor, const Color(0x88eaded0));
    });

    test('should have correct primaryButtonColor value', () {
      expect(ColorManager.primaryButtonColor, const Color(0xff009688));
    });

    test('should have correct defaultWaveform value', () {
      expect(ColorManager.defaultWaveform, const Color(0xff178b51));
    });

    test('should have correct defaultWaveformFill value', () {
      expect(ColorManager.defaultWaveformFill, const Color(0xff80FFC0));
    });

    test('should have correct defaultPlaybackIndicator value', () {
      expect(ColorManager.defaultPlaybackIndicator, const Color(0xffffff66));
    });

    test('should have correct defaultTimecode value', () {
      expect(ColorManager.defaultTimecode, const Color(0xddffffdd));
    });

    test('should have correct colorAbnormal value', () {
      expect(ColorManager.colorAbnormal, const Color(0xffB72846));
    });

    test('should have correct colorAtypical value', () {
      expect(ColorManager.colorAtypical, const Color(0xff141414));
    });

    test('should have correct colorNotification value', () {
      expect(ColorManager.colorNotification, const Color(0xffF2F2F2));
    });

    test('should have correct colorNSTBackground value', () {
      expect(ColorManager.colorNSTBackground, const Color(0xff403c36));
    });

    test('should have correct waveformSelected value', () {
      expect(ColorManager.waveformSelected, const Color(0xff009688));
    });

    test('should have correct waveformUnselected value', () {
      expect(ColorManager.waveformUnselected, const Color(0xff106072));
    });

    test('should have correct waveformUnselectedBgOverlay value', () {
      expect(ColorManager.waveformUnselectedBgOverlay, Colors.transparent);
    });

    test('should have correct selectionBorder value', () {
      expect(ColorManager.selectionBorder, const Color(0xffffffff));
    });

    test('should have correct playbackIndicator value', () {
      expect(ColorManager.playbackIndicator, const Color(0xffffff66));
    });

    test('should have correct gridLine value', () {
      expect(ColorManager.gridLine, const Color(0xee01a9a9));
    });

    test('should have correct timecode value', () {
      expect(ColorManager.timecode, const Color(0xddffffdd));
    });

    test('should have correct timecodeShadow value', () {
      expect(ColorManager.timecodeShadow, const Color(0xaa000000));
    });
  });
}