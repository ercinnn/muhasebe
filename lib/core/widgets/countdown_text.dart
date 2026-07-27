import 'dart:async';

import 'package:flutter/material.dart';

/// Live "Xsa Ydk kaldı" ticker for the final 24 hours before [dueDate].
/// Outside that window it just renders [fallbackLabel] as static text — no
/// `Timer` runs, so this stays cheap to use in a long scrolling list.
class CountdownText extends StatefulWidget {
  const CountdownText({super.key, required this.dueDate, required this.fallbackLabel, this.style});

  final DateTime dueDate;
  final String fallbackLabel;
  final TextStyle? style;

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  Timer? _timer;

  Duration get _remaining => widget.dueDate.difference(DateTime.now());

  bool get _inFinalHours => _remaining.inSeconds > 0 && _remaining.inHours < 24;

  @override
  void initState() {
    super.initState();
    if (_inFinalHours) _startTicking();
  }

  void _startTicking() {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      if (!_inFinalHours) {
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_inFinalHours) {
      return Text(widget.fallbackLabel, style: widget.style);
    }
    final remaining = _remaining;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    return Text('${hours}sa ${minutes}dk kaldı', style: widget.style);
  }
}
