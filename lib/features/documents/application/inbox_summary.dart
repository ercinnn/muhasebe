import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/document_enums.dart';
import '../../../core/utils/formatters.dart';
import '../data/documents_repository.dart';
import '../domain/document_record.dart';

part 'inbox_summary.g.dart';

/// Drives the client's web visual notifications: unread-document badge and
/// the "yaklaşan ödemeler (7 gün)" banner. Backed by the same Realtime
/// stream the Ödemeler/Takvim screens already use, so it updates live.
class InboxSummary {
  const InboxSummary({
    required this.unreadCount,
    required this.upcomingCount,
    required this.upcomingTotal,
    required this.pendingCount,
    required this.pendingTotal,
  });

  final int unreadCount;
  final int upcomingCount;
  final double upcomingTotal;

  /// All pending payments regardless of due date — distinct from
  /// [upcomingTotal], which only sums the 7-day window shown in the banner.
  final int pendingCount;
  final double pendingTotal;
}

@riverpod
InboxSummary inboxSummary(Ref ref) {
  final docs = ref.watch(clientDocumentsProvider).value ?? const [];
  return computeInboxSummary(docs);
}

/// Pure computation extracted from [inboxSummary] so it's unit-testable
/// with a plain list of [DocumentRecord] fixtures, without needing a
/// Riverpod container or a live `clientDocumentsProvider` stream.
InboxSummary computeInboxSummary(List<DocumentRecord> docs) {
  final unreadCount = docs.where((d) => d.seenAt == null).length;

  final pending = docs.where(
    (d) => d.category == DocumentCategory.payment && d.status == DocumentStatus.pending,
  );
  final pendingTotal = pending.fold<double>(0, (sum, d) => sum + (d.amount ?? 0));

  final upcoming = pending.where((d) => d.dueDate != null && daysUntil(d.dueDate!) <= 7);
  final upcomingTotal = upcoming.fold<double>(0, (sum, d) => sum + (d.amount ?? 0));

  return InboxSummary(
    unreadCount: unreadCount,
    upcomingCount: upcoming.length,
    upcomingTotal: upcomingTotal,
    pendingCount: pending.length,
    pendingTotal: pendingTotal,
  );
}
