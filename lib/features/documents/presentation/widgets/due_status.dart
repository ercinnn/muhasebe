import 'package:flutter/material.dart';

import '../../../../core/constants/document_enums.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/document_record.dart';

enum DueUrgency { paid, noPayment, info, overdue, soon, upcoming, unknown }

/// Color + label for a payment document's due-date urgency, per spec:
/// vadesi geçen kırmızı, ≤3 gün turuncu, ödendi yeşil, diğerleri nötr.
class DueStatus {
  const DueStatus({required this.urgency, required this.color, required this.label});

  final DueUrgency urgency;
  final Color color;
  final String label;

  static DueStatus of(DocumentRecord doc) {
    if (doc.status == DocumentStatus.paid) {
      return const DueStatus(urgency: DueUrgency.paid, color: urgencyPaid, label: 'Ödendi');
    }
    if (doc.status == DocumentStatus.noPayment) {
      return const DueStatus(
        urgency: DueUrgency.noPayment,
        color: urgencyNeutral,
        label: 'Ödeme gerekmez',
      );
    }
    if (doc.status == DocumentStatus.info) {
      return const DueStatus(
        urgency: DueUrgency.info,
        color: urgencyNeutral,
        label: 'Bilgilendirme',
      );
    }
    final due = doc.dueDate;
    if (due == null) {
      return const DueStatus(
        urgency: DueUrgency.unknown,
        color: urgencyNeutral,
        label: 'Vade belirtilmemiş',
      );
    }

    final days = daysUntil(due);
    if (days < 0) {
      return const DueStatus(urgency: DueUrgency.overdue, color: urgencyOverdue, label: 'Vadesi geçti');
    }
    if (days <= 3) {
      return DueStatus(
        urgency: DueUrgency.soon,
        color: urgencySoon,
        label: days == 0 ? 'Bugün son gün' : '$days gün kaldı',
      );
    }
    return DueStatus(
      urgency: DueUrgency.upcoming,
      color: urgencyUpcoming,
      label: '$days gün kaldı',
    );
  }
}
