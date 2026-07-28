import '../../core/constants/document_enums.dart';
import '../../features/documents/domain/document_record.dart';
import '../../features/settings/data/settings_repository.dart';
import 'notification_service.dart';

/// Web build: no local notifications. Visual notifications for web are
/// handled separately (WebNotificationService, Faz 7). Takes a
/// [SettingsRepository] to keep the constructor signature identical to the
/// mobile implementation the platform-conditional export switches between.
class NotificationServiceImpl implements NotificationService {
  // ignore: avoid_unused_constructor_parameters
  NotificationServiceImpl(SettingsRepository settings);

  @override
  Future<void> init({bool requestPermission = true}) async {}

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
