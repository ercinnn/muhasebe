import 'package:flutter/material.dart';

import '../utils/formatters.dart';

/// Counts up to [value] (formatted as Turkish currency) whenever it
/// changes — used for the payments hero card's total.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  final double value;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) =>
          Text(formatCurrencyTr(animatedValue), style: style),
    );
  }
}
