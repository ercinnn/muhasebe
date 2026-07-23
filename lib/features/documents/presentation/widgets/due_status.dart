import 'package:flutter/material.dart';

import '../../../../core/constants/document_enums.dart';
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
      return const DueStatus(urgency: DueUrgency.paid, color: Colors.green, label: 'Ödendi');
    }
    if (doc.status == DocumentStatus.noPayment) {
      return const DueStatus(
        urgency: DueUrgency.noPayment,
        color: Colors.grey,
        label: 'Ödeme gerekmez',
      );
    }
    if (doc.status == DocumentStatus.info) {
      return const DueStatus(
        urgency: DueUrgency.info,
        color: Colors.blueGrey,
        label: 'Bilgilendirme',
      );
    }
    final due = doc.dueDate;
    if (due == null) {
      return const DueStatus(
        urgency: DueUrgency.unknown,
        color: Colors.grey,
        label: 'Vade belirtilmemiş',
      );
    }

    final days = daysUntil(due);
    if (days < 0) {
      return DueStatus(urgency: DueUrgency.overdue, color: Colors.red.shade700, label: 'Vadesi geçti');
    }
    if (days <= 3) {
      return DueStatus(
        urgency: DueUrgency.soon,
        color: Colors.orange.shade800,
        label: days == 0 ? 'Bugün son gün' : '$days gün kaldı',
      );
    }
    return DueStatus(
      urgency: DueUrgency.upcoming,
      color: Colors.blueGrey.shade700,
      label: '$days gün kaldı',
    );
  }
}
