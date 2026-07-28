import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/document_enums.dart';
import '../../core/utils/formatters.dart';
import '../../features/documents/domain/document_record.dart';
import '../../features/settings/data/settings_repository.dart';
import 'notification_service.dart';

// _v2: Android notification channels are immutable after first creation —
// bumping the id forces a fresh channel with the alarm-style settings below
// (the original 'payment_reminders' channel got created silently on some
// devices during earlier testing and can't be fixed in place).
const _channelId = 'payment_reminders_v2';
const _channelName = 'Vade Hatırlatmaları (Alarm)';
const _newDocChannelId = 'new_document';
const _newDocChannelName = 'Yeni Belge Bildirimleri';

/// Mobile: schedules local notifications at 09:00 on due-date-minus-1-day
/// and due-date for pending payment documents.
class NotificationServiceImpl implements NotificationService {
  NotificationServiceImpl(this._settings, [FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final SettingsRepository _settings;
  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> init({bool requestPermission = true}) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    if (!requestPermission) return;
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

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
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        iOS: DarwinNotificationDetails(interruptionLevel: InterruptionLevel.timeSensitive),
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
