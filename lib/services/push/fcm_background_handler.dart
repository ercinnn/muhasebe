import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/document_enums.dart';
import '../../firebase_options.dart';
import '../notifications/notification_service_mobile.dart';
import 'push_payload.dart';

/// Runs in a separate isolate with no app/Riverpod state (the app may be
/// fully terminated), so it initializes everything it needs from scratch —
/// including the timezone database (bootstrap.dart's initialization never
/// runs here since this isolate skips bootstrap() entirely). Without it,
/// scheduleReminder's tz.local throws LateInitializationError, since the
/// `timezone` package's local location is never set to anything, not even
/// a UTC fallback.
/// Must stay a top-level function per firebase_messaging's requirements.
@pragma('vm:entry-point')
Future<void> fcmBackgroundMessageHandler(RemoteMessage message) async {
  final payload = PushPayload.fromData(message.data);
  if (payload == null) return;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

  final service = NotificationServiceImpl();
  await service.init(requestPermission: false);
  await service.showNewDocumentNotification(
    documentId: payload.documentId,
    docType: payload.docType,
    amount: payload.amount,
  );

  final dueDate = payload.dueDate;
  if (payload.category == DocumentCategory.payment && dueDate != null) {
    await service.scheduleReminder(
      documentId: payload.documentId,
      dueDate: dueDate,
      docType: payload.docType,
      amount: payload.amount,
    );
  }
}
