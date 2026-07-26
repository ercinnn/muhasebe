import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/document_enums.dart';
import '../../core/utils/formatters.dart';
import '../../features/documents/domain/document_record.dart';
import '../../features/settings/data/settings_repository.dart';
import 'notification_service.dart';

const _channelId = 'payment_reminders';
const _channelName = 'Ödeme Hatırlatmaları';
const _newDocChannelId = 'new_document';
const _newDocChannelName = 'Yeni Belge Bildirimleri';

/// Mobile: schedules local notifications at 09:00 on due-date-minus-1-day
/// and due-date for pending payment documents.
class NotificationServiceImpl implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  final _settings = SettingsRepository();

  @override
  Future<void> showNewDocumentNotification({
    required String documentId,
    required DocType docType,
    double? amount,
  }) async {
    final body = amount != null ? '${docType.label}: ${formatCurrencyTr(amount)}' : docType.label;
    await _plugin.show(
      id: _notificationId(documentId, isDueDay: false) + 2,
      title: 'Belge Geldi',
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(_newDocChannelId, _newDocChannelName),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> scheduleReminder({
    required String documentId,
    required DateTime dueDate,
    required DocType docType,
    double? amount,
  }) async {
    await cancelReminders(documentId);

    final body = amount != null ? '${docType.label}: ${formatCurrencyTr(amount)}' : docType.label;
    final daysBefore = await _settings.getReminderDaysBefore();
    final hour = await _settings.getReminderHour();

    if (daysBefore > 0) {
      await _scheduleAt(
        id: _notificationId(documentId, isDueDay: false),
        date: dueDate.subtract(Duration(days: daysBefore)),
        hour: hour,
        title: daysBefore == 1 ? 'Yarın son ödeme günü' : '$daysBefore gün sonra son ödeme günü',
        body: body,
      );
    }
    await _scheduleAt(
      id: _notificationId(documentId, isDueDay: true),
      date: dueDate,
      hour: hour,
      title: 'Bugün son ödeme günü',
      body: body,
    );
  }

  Future<void> _scheduleAt({
    required int id,
    required DateTime date,
    required int hour,
    required String title,
    required String body,
  }) async {
    final scheduled = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
    );
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(_channelId, _channelName),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelReminders(String documentId) async {
    await _plugin.cancel(id: _notificationId(documentId, isDueDay: false));
    await _plugin.cancel(id: _notificationId(documentId, isDueDay: true));
  }

  @override
  Future<void> resyncFromServer(List<DocumentRecord> pendingPayments) async {
    await _plugin.cancelAll();
    for (final document in pendingPayments) {
      final dueDate = document.dueDate;
      if (dueDate == null) continue;
      if (document.category != DocumentCategory.payment) continue;
      if (document.status != DocumentStatus.pending) continue;
      await scheduleReminder(
        documentId: document.id,
        dueDate: dueDate,
        docType: document.docType,
        amount: document.amount,
      );
    }
  }

  /// Stable int32 notification id derived from the document's UUID, with
  /// distinct ids for the due-1 and due-day alarms of the same document.
  int _notificationId(String documentId, {required bool isDueDay}) {
    final base = (documentId.hashCode & 0x3FFFFFFF) * 2;
    return isDueDay ? base + 1 : base;
  }
}
