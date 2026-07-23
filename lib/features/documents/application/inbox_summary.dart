import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/document_enums.dart';
import '../../../core/utils/formatters.dart';
import '../data/documents_repository.dart';

part 'inbox_summary.g.dart';

/// Drives the client's web visual notifications: unread-document badge and
/// the "yaklaşan ödemeler (7 gün)" banner. Backed by the same Realtime
/// stream the Ödemeler/Takvim screens already use, so it updates live.
class InboxSummary {
  const InboxSummary({
    required this.unreadCount,
    required this.upcomingCount,
    required this.upcomingTotal,
  });

  final int unreadCount;
  final int upcomingCount;
  final double upcomingTotal;
}

@riverpod
InboxSummary inboxSummary(Ref ref) {
  final docs = ref.watch(clientDocumentsProvider).value ?? const [];

  final unreadCount = docs.where((d) => d.seenAt == null).length;

  final upcoming = docs.where(
    (d) =>
        d.category == DocumentCategory.payment &&
        d.status == DocumentStatus.pending &&
        d.dueDate != null &&
        daysUntil(d.dueDate!) <= 7,
  );

  final upcomingTotal = upcoming.fold<double>(0, (sum, d) => sum + (d.amount ?? 0));

  return InboxSummary(
    unreadCount: unreadCount,
    upcomingCount: upcoming.length,
    upcomingTotal: upcomingTotal,
  );
}
