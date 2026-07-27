/// Central Glassmorphism palette + style constants — the single source of
/// truth for the gradient background, glass fill/border/shadow values, and
/// due-date urgency colors (also consumed by
/// `features/documents/presentation/widgets/due_status.dart` and
/// `features/documents/presentation/client/calendar_screen.dart`, which
/// used to each hardcode their own copy of the urgency→color mapping).
library;

import 'package:flutter/material.dart';

const _seed = Color(0xFF4F5FE0);

ColorScheme buildAppColorScheme() =>
    ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light);

/// Shared backdrop every glass-styled screen sits on — glass fills/borders
/// are only legible as "glass" against a colorful, non-flat background.
const appBackgroundGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFEEF1FF), Color(0xFFE3E9FD), Color(0xFFDCEBFB)],
);

class GlassStyle {
  const GlassStyle._();

  static const double cardRadius = 24;
  static const double surfaceRadius = 18;
  static const double blurSigma = 24;
  static const Color borderColor = Color(0xB3FFFFFF);
  static const double borderWidth = 1.2;
  static const Color fillColor = Color(0x99FFFFFF);
  static const List<BoxShadow> shadow = [
    BoxShadow(color: Color(0x1A1B2559), blurRadius: 24, offset: Offset(0, 10)),
  ];
}

/// Due-date urgency colors — mirrors the semantics previously hardcoded in
/// `due_status.dart` (paid=green, overdue=red, ≤3 gün=amber, else=neutral
/// blue-grey) so restyling doesn't change what any color *means*.
const Color urgencyPaid = Color(0xFF2E9E5B);
const Color urgencyNeutral = Color(0xFF78829A);
const Color urgencyOverdue = Color(0xFFD64545);
const Color urgencySoon = Color(0xFFE08A2B);
const Color urgencyUpcoming = Color(0xFF4A6FA5);
