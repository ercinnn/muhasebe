import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/notifications/notification_providers.dart';
import '../data/documents_repository.dart';

part 'document_actions.g.dart';

/// Combines the DB write with its client-side side effect (cancelling the
/// mobile local reminder — a no-op on web) so both call sites stay in sync.
@riverpod
class DocumentActions extends _$DocumentActions {
  @override
  void build() {}

  Future<void> markPaid(String documentId) async {
    await ref.read(documentsRepositoryProvider).markPaid(documentId);
    await ref.read(notificationServiceProvider).cancelReminders(documentId);
  }
}
