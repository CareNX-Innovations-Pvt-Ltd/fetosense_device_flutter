import 'package:flutter/material.dart';

/// A stateless widget that animates the transition of an integer value.
///
/// `AnimatedCount` smoothly animates from 0 to the specified [count] over the given [duration].
/// It uses a [TweenAnimationBuilder] with an [IntTween] to update the displayed value,
/// applying the provided [style] to the text.
///
/// Example usage:
/// ```dart
/// AnimatedCount(
///   count: 100,
///   style: TextStyle(fontSize: 24, color: Colors.black),
///   duration: Duration(seconds: 2),
/// )
/// ```

class AnimatedCount extends StatelessWidget {
  final int count;
  final TextStyle style;
  final Duration duration;

  const AnimatedCount({
    super.key,
    required this.count,
    required this.style,
    this.duration = const Duration(seconds: 1),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: count),
      duration: duration,
      builder: (context, value, _) {
        return Text(
          value.toString(),
          style: style,
        );
      },
    );
  }
}
