import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/notifications/notification_providers.dart';
import '../data/documents_repository.dart';

part 'document_actions.g.dart';

/// Combines the DB write with its client-side side effect (cancelling the
/// mobile local reminder — a no-op on web) so both call sites stay in sync.
///
/// keepAlive: this provider is only ever `ref.read(...).notifier`'d from a
/// button's onPressed, never `ref.watch`'d — an autodispose instance can get
/// disposed mid-`markPaid()` (multiple awaits in a row), throwing "Cannot
/// use the Ref after it has been disposed" and silently dropping whatever
/// ran after the point of disposal (see `fcmServiceProvider` for the same
/// pattern).
@Riverpod(keepAlive: true)
class DocumentActions extends _$DocumentActions {
  @override
  void build() {}

  Future<void> markPaid(String documentId) async {
    await ref.read(documentsRepositoryProvider).markPaid(documentId);
    await ref.read(notificationServiceProvider).cancelReminders(documentId);
    // documentByIdProvider is a one-shot Future (unlike the Realtime-backed
    // client/accountant document list streams), so document_detail_screen's
    // "Ödendi" button won't reflect the change until this is invalidated.
    ref.invalidate(documentByIdProvider(documentId));
  }
}
