import 'dart:math';

import 'package:flutter/material.dart';

/// Wraps [child] with a horizontal shake + brief red flash whenever
/// [trigger] changes value (bump a counter to fire a new shake) — for
/// validation/upload-error feedback.
class ShakeWrapper extends StatefulWidget {
  const ShakeWrapper({super.key, required this.trigger, required this.child});

  final Object trigger;
  final Widget child;

  @override
  State<ShakeWrapper> createState() => _ShakeWrapperState();
}

class _ShakeWrapperState extends State<ShakeWrapper> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void didUpdateWidget(covariant ShakeWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final dx = sin(t * pi * 8) * (1 - t) * 10;
        final flashOpacity = t == 0 ? 0.0 : (1 - t).clamp(0.0, 1.0) * 0.25;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Stack(
            children: [
              child!,
              if (flashOpacity > 0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.red.withValues(alpha: flashOpacity)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}
