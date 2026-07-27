import 'package:flutter/material.dart';

/// A translucent glass pill for a short status label — color/label are
/// supplied by the caller (e.g. `DueStatus.of(document)`), this widget only
/// provides the glass visual treatment.
///
/// Pass [child] (e.g. a `CountdownText`) instead of relying on [label] when
/// the content needs to be dynamic — [label] is still required as a
/// semantic fallback/description.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color, this.child});

  final String label;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child:
          child ??
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
