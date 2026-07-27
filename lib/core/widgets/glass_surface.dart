import 'package:flutter/material.dart';

import '../theme/glass_theme.dart';

/// The list-safe glass variant: same fill/border/shadow recipe as
/// [GlassCard] but no `BackdropFilter` blur, so it's cheap to repeat inside
/// a scrolling `ListView` (list tiles, draft cards).
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.tint,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(GlassStyle.surfaceRadius);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? GlassStyle.fillColor,
        borderRadius: radius,
        border: Border.all(color: GlassStyle.borderColor, width: GlassStyle.borderWidth),
        boxShadow: GlassStyle.shadow,
      ),
      child: child,
    );
  }
}
