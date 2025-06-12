import 'package:flutter/material.dart';

/// Provides a centralized set of color constants for consistent theming across the app.
///
/// This abstract class defines static color values used for UI elements such as
/// backgrounds, buttons, waveforms, indicators, and notifications. Using these
/// constants ensures a unified color scheme and simplifies color management.
///
/// Example usage:
/// ```dart
/// Container(color: ColorManager.primaryColor)
/// ```

abstract class ColorManager {
  static const white = Color(0xffffffff);
  static const black = Color(0xff000000);
  static const primaryColor = Color(0x88eaded0);
  static const primaryButtonColor = Color(0xff009688);
  static const defaultWaveform = Color(0xff178b51);
  static const defaultWaveformFill = Color(0xff80FFC0);
  static const defaultPlaybackIndicator = Color(0xffffff66);
  static const defaultTimecode = Color(0xddffffdd);
  static const colorAbnormal = Color(0xffB72846);
  static const colorAtypical = Color(0xff141414);
  static const colorNotification = Color(0xffF2F2F2);
  static const colorNSTBackground = Color(0xff403c36);
  static const waveformSelected = Color(0xff009688);
  static const waveformUnselected = Color(0xff106072);
  static const waveformUnselectedBgOverlay = Colors.transparent;
  static const selectionBorder = Color(0xffffffff);
  static const playbackIndicator = Color(0xffffff66);
  static const gridLine = Color(0xee01a9a9);
  static const timecode = Color(0xddffffdd);
  static const timecodeShadow = Color(0xaa000000);
}
