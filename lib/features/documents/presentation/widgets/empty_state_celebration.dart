import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/glass_theme.dart';
import '../../../../core/widgets/glass_card.dart';

/// Shown when a client has zero pending payments — a short confetti burst
/// plus a glass "all caught up" badge.
class EmptyStateCelebration extends StatefulWidget {
  const EmptyStateCelebration({super.key});

  @override
  State<EmptyStateCelebration> createState() => _EmptyStateCelebrationState();
}

class _EmptyStateCelebrationState extends State<EmptyStateCelebration> {
  late final ConfettiController _confetti = ConfettiController(duration: const Duration(seconds: 2))
    ..play();

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirection: pi / 2,
                maxBlastForce: 12,
                minBlastForce: 6,
                numberOfParticles: 24,
                gravity: 0.25,
                shouldLoop: false,
              ),
            ),
          ),
        ),
        Center(
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.celebration_outlined, size: 40, color: urgencyPaid),
                const SizedBox(height: 12),
                Text(
                  'Tüm ödemeleriniz güncel!',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Bekleyen bir ödemeniz bulunmuyor.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
