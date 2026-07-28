import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:muhasebe_takip/core/constants/document_enums.dart';
import 'package:muhasebe_takip/features/documents/domain/document_record.dart';
import 'package:muhasebe_takip/features/settings/data/settings_repository.dart';
import 'package:muhasebe_takip/services/notifications/notification_service_mobile.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockFlutterLocalNotificationsPlugin plugin;
  late MockSettingsRepository settings;
  late NotificationServiceImpl service;

  setUpAll(() {
    // Mirrors fcm_background_handler.dart's manual bootstrap — nothing sets
    // this up implicitly outside a running app.
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
  });

  setUp(() {
    plugin = MockFlutterLocalNotificationsPlugin();
    settings = MockSettingsRepository();
    when(() => settings.getReminderHour()).thenAnswer((_) async => 9);
    when(() => settings.getReminderDaysBefore()).thenAnswer((_) async => 1);
    when(() => plugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
    when(() => plugin.cancelAll()).thenAnswer((_) async {});
    when(
      () => plugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
      ),
    ).thenAnswer((_) async {});
    service = NotificationServiceImpl(settings, plugin);
  });

  DateTime todayAt(int daysFromNow) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: daysFromNow));
  }

  DocumentRecord doc({
    DocumentCategory category = DocumentCategory.payment,
    DocumentStatus status = DocumentStatus.pending,
    DateTime? dueDate,
  }) => DocumentRecord(
    id: 'doc-${dueDate?.millisecondsSinceEpoch ?? 0}-${category.name}-${status.name}',
    createdAt: DateTime(2026, 1, 1),
    accountantId: 'accountant-1',
    clientId: 'client-1',
    category: category,
    docType: DocType.kdv,
    amount: 100,
    dueDate: dueDate,
    storagePath: 'path.pdf',
    status: status,
  );

  group('scheduleReminder', () {
    test('schedules both the due-1 and due-day alarms for a future due date', () async {
      await service.scheduleReminder(
        documentId: 'doc-1',
        dueDate: todayAt(5),
        docType: DocType.kdv,
        amount: 100,
      );

      verify(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      ).called(2);
    });

    test('skips the due-1 alarm when reminderDaysBefore is 0, but keeps the due-day one', () async {
      when(() => settings.getReminderDaysBefore()).thenAnswer((_) async => 0);

      await service.scheduleReminder(
        documentId: 'doc-2',
        dueDate: todayAt(5),
        docType: DocType.kdv,
        amount: 100,
      );

      verify(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      ).called(1);
    });

    test('schedules nothing when both alarm dates land in the past', () async {
      await service.scheduleReminder(
        documentId: 'doc-3',
        dueDate: todayAt(-3),
        docType: DocType.kdv,
        amount: 100,
      );

      verifyNever(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      );
    });

    test('still schedules the due-day alarm even when the due-1 alarm date is in the past', () async {
      // A large reminderDaysBefore pushes the due-1 alarm's target date deep
      // into the past while the due-day alarm (5 days out) stays in the
      // future — deterministic regardless of what time of day the test runs.
      when(() => settings.getReminderDaysBefore()).thenAnswer((_) async => 1000);

      await service.scheduleReminder(
        documentId: 'doc-4',
        dueDate: todayAt(5),
        docType: DocType.kdv,
        amount: 100,
      );

      verify(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      ).called(1);
    });
  });

  group('resyncFromServer', () {
    test('cancels everything up front', () async {
      await service.resyncFromServer(const []);

      verify(() => plugin.cancelAll()).called(1);
    });

    test('reschedules only pending payment docs that have a due date', () async {
      final docs = [
        doc(dueDate: todayAt(2)), // qualifies: payment + pending + due date
        doc(status: DocumentStatus.paid, dueDate: todayAt(2)), // already paid
        doc(category: DocumentCategory.info, status: DocumentStatus.info, dueDate: todayAt(2)),
        doc(dueDate: null), // no due date to schedule against
      ];

      await service.resyncFromServer(docs);

      // Only the first document qualifies, and it schedules 2 alarms
      // (due-1 + due-day) since both land in the future.
      verify(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      ).called(2);
    });
  });
}
