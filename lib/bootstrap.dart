import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'core/config/env.dart';
import 'firebase_options.dart';
import 'services/push/fcm_background_handler.dart';

/// Platform-independent app bootstrap. Mobile-only: Firebase + FCM
/// background handler registration (must happen early, per
/// firebase_messaging's requirements). Web never touches Firebase — no
/// push there, per spec.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.assertConfigured();

  tz_data.initializeTimeZones();
  // The `timezone` package defaults tz.local to UTC otherwise — this app is
  // Turkey-only (see the hardcoded 'tr_TR' locale below), so hardcode the
  // location rather than pull in a device-timezone-detection plugin.
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  await initializeDateFormatting('tr_TR');
  await pdfrxFlutterInitialize();

  if (!kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(fcmBackgroundMessageHandler);
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
}
