import 'package:flutter/material.dart';

import '../theme/glass_theme.dart';

/// Wraps a screen body in the app's shared glass-friendly gradient backdrop.
/// Pair with a transparent `Scaffold`/`AppBar` on that specific screen so
/// the gradient shows through under the nav shell.
class GradientScaffoldBackground extends StatelessWidget {
  const GradientScaffoldBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(decoration: const BoxDecoration(gradient: appBackgroundGradient), child: child);
  }
}
