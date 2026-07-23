import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/config/env.dart';

/// Platform-independent app bootstrap. Mobile-only setup (Firebase, FCM,
/// local notifications) lives in services/notifications and services/push
/// and is wired in from main.dart behind a `!kIsWeb` guard, not here.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.assertConfigured();

  tz_data.initializeTimeZones();
  await initializeDateFormatting('tr_TR');
  await pdfrxFlutterInitialize();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
}
