import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../firebase_options.dart';
import '../notifications/notification_service_mobile.dart';
import 'push_payload.dart';

/// Runs in a separate isolate with no app/Riverpod state (the app may be
/// fully terminated), so it initializes everything it needs from scratch.
/// Must stay a top-level function per firebase_messaging's requirements.
@pragma('vm:entry-point')
Future<void> fcmBackgroundMessageHandler(RemoteMessage message) async {
  final payload = PushPayload.fromData(message.data);
  if (payload == null) return;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final service = NotificationServiceImpl();
  await service.init();
  await service.scheduleReminder(
    documentId: payload.documentId,
    dueDate: payload.dueDate,
    docType: payload.docType,
    amount: payload.amount,
  );
}
