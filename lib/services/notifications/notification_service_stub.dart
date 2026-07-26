import '../../core/constants/document_enums.dart';
import '../../features/documents/domain/document_record.dart';
import 'notification_service.dart';

/// Web build: no local notifications. Visual notifications for web are
/// handled separately (WebNotificationService, Faz 7).
class NotificationServiceImpl implements NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> showNewDocumentNotification({
    required String documentId,
    required DocType docType,
    double? amount,
  }) async {}

  @override
  Future<void> scheduleReminder({
    required String documentId,
    required DateTime dueDate,
    required DocType docType,
    double? amount,
  }) async {}

  @override
  Future<void> cancelReminders(String documentId) async {}

  @override
  Future<void> resyncFromServer(List<DocumentRecord> pendingPayments) async {}
}
