import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/glass_theme.dart';

enum _CheckState { idle, loading, success }

/// Wraps a "mark as done" action button: press → loading spinner →
/// checkmark scale-in, plus a single `HapticFeedback` call site (safe/no-op
/// on web — don't scatter `kIsWeb` guards at each call site instead).
///
/// The parent is expected to rebuild without this button shortly after
/// (the underlying data changes once [onPressed] completes), so this only
/// needs to bridge the visual gap while the async action is in flight.
class SuccessCheckAnimation extends StatefulWidget {
  const SuccessCheckAnimation({super.key, required this.label, required this.onPressed});

  final String label;
  final Future<void> Function() onPressed;

  @override
  State<SuccessCheckAnimation> createState() => _SuccessCheckAnimationState();
}

class _SuccessCheckAnimationState extends State<SuccessCheckAnimation> {
  _CheckState _state = _CheckState.idle;

  Future<void> _handlePressed() async {
    setState(() => _state = _CheckState.loading);
    await widget.onPressed();
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() => _state = _CheckState.success);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: switch (_state) {
        _CheckState.idle => FilledButton.tonal(
          key: const ValueKey('idle'),
          onPressed: _handlePressed,
          child: Text(widget.label),
        ),
        _CheckState.loading => const SizedBox(
          key: ValueKey('loading'),
          width: 36,
          height: 36,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
        _CheckState.success => const Icon(
          Icons.check_circle,
          key: ValueKey('success'),
          color: urgencyPaid,
          size: 32,
        ),
      },
    );
  }
}
