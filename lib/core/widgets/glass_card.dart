import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/glass_theme.dart';

/// A translucent, real-blur "glass" surface for singular, non-scrolling UI
/// (hero cards, bottom sheets, empty-state cards).
///
/// Do not use inside a scrolling list — each instance forces an expensive
/// offscreen `BackdropFilter` layer; use [GlassSurface] there instead.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
    this.tint,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(GlassStyle.cardRadius);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: GlassStyle.shadow),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: GlassStyle.blurSigma, sigmaY: GlassStyle.blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tint ?? GlassStyle.fillColor,
              borderRadius: radius,
              border: Border.all(color: GlassStyle.borderColor, width: GlassStyle.borderWidth),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
