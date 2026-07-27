import 'package:flutter/material.dart';

/// Wraps [child] in a subtle, repeating scale pulse — used to draw the eye
/// to due-date badges/rows that are urgent (due today or tomorrow). No
/// ticker runs while [enabled] is false, so it's cheap to leave in a list.
class PulseWrapper extends StatefulWidget {
  const PulseWrapper({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<PulseWrapper> createState() => _PulseWrapperState();
}

class _PulseWrapperState extends State<PulseWrapper> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _scale = Tween(
    begin: 1.0,
    end: 1.05,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant PulseWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
