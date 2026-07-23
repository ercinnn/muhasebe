import '../../core/constants/document_enums.dart';
import '../../features/documents/domain/document_record.dart';

export 'notification_service_stub.dart' if (dart.library.io) 'notification_service_mobile.dart';

/// Platform-gated local reminder scheduling. Web resolves to a no-op
/// (notification_service_stub.dart) — visual-only badges/banners for web
/// are WebNotificationService (Faz 7), layered on top of Realtime, not
/// this interface. Mobile (notification_service_mobile.dart) schedules
/// due-1-day/due-day local alarms at 09:00 via flutter_local_notifications.
abstract class NotificationService {
  Future<void> init();

  /// Schedules (replacing any existing ones) the due-1 and due-day
  /// reminders for a pending payment. Takes the raw fields rather than a
  /// [DocumentRecord] because the same call is made both from a full DB
  /// row (resync) and from an FCM push payload, which only carries these.
  Future<void> scheduleReminder({
    required String documentId,
    required DateTime dueDate,
    required DocType docType,
    double? amount,
  });

  Future<void> cancelReminders(String documentId);

  /// Cancels every scheduled reminder and reschedules from [pendingPayments]
  /// (the current source of truth from the server) — called on every app
  /// launch so a missed push doesn't leave the client without a reminder.
  Future<void> resyncFromServer(List<DocumentRecord> pendingPayments);
}
