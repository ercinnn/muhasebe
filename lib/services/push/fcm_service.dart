import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/document_enums.dart';
import '../notifications/notification_providers.dart';
import '../supabase/supabase_providers.dart';
import 'fcm_background_handler.dart';
import 'push_payload.dart';

part 'fcm_service.g.dart';

/// Mobile-only: requests notification permission, registers/refreshes this
/// device's FCM token in `device_tokens`, and schedules a local reminder
/// whenever a `new_document` push arrives in the foreground.
class FcmService {
  FcmService(this._ref);

  final Ref _ref;

  Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    FirebaseMessaging.onBackgroundMessage(fcmBackgroundMessageHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    final token = await messaging.getToken();
    if (token != null) await _registerToken(token);
    messaging.onTokenRefresh.listen(_registerToken);
  }

  Future<void> _registerToken(String token) async {
    final client = _ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client
        .from('device_tokens')
        .upsert({
          'user_id': userId,
          'token': token,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,token');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final payload = PushPayload.fromData(message.data);
    if (payload == null) return;

    final notificationService = _ref.read(notificationServiceProvider);
    await notificationService.showNewDocumentNotification(
      documentId: payload.documentId,
      docType: payload.docType,
      amount: payload.amount,
    );

    final dueDate = payload.dueDate;
    if (payload.category == DocumentCategory.payment && dueDate != null) {
      await notificationService.scheduleReminder(
        documentId: payload.documentId,
        dueDate: dueDate,
        docType: payload.docType,
        amount: payload.amount,
      );
    }
  }
}

// keepAlive: this service holds long-lived stream subscriptions
// (onMessage, onTokenRefresh) that must outlive the widget that triggered
// initialize() — an autodispose provider gets torn down as soon as nothing
// is actively watching it, which cancels those listeners (and can crash
// pending async work, e.g. `initialize()` still awaiting `getToken()`).
@Riverpod(keepAlive: true)
FcmService fcmService(Ref ref) => FcmService(ref);
