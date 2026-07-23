import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../services/notifications/notification_providers.dart';
import '../../../services/push/fcm_service.dart';
import '../../auth/application/auth_controller.dart';
import '../../settings/presentation/settings_screen.dart';
import '../data/documents_repository.dart';
import 'client/calendar_screen.dart';
import 'client/info_screen.dart';
import 'client/payments_screen.dart';

/// Shell for the client role: Ödemeler / Takvim / Bilgilendirme / Ayarlar.
/// On mobile, also boots FCM + resyncs local reminder alarms from the
/// server on every launch (in case a push was missed while the app was
/// closed).
class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  int _index = 0;

  static const _destinations = [
    AdaptiveDestination(icon: Icons.payments_outlined, label: 'Ödemeler'),
    AdaptiveDestination(icon: Icons.calendar_month_outlined, label: 'Takvim'),
    AdaptiveDestination(icon: Icons.info_outline, label: 'Bilgilendirme'),
    AdaptiveDestination(icon: Icons.settings_outlined, label: 'Ayarlar'),
  ];

  static const _titles = ['Ödemeler', 'Takvim', 'Bilgilendirme', 'Ayarlar'];

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Fire-and-forget: build() can't be async, so this needs an eager
      // Future wrapper (Postgrest/RPC builders are lazy — see
      // document_detail_screen.dart for the same pattern).
      Future(_setUpMobileNotifications);
    }
  }

  /// Each step can fail independently without blocking the others — e.g.
  /// FCM registration needs a real Firebase project to succeed, but local
  /// reminder resync only needs Supabase and must still run even if FCM
  /// setup fails (as it will until real Firebase credentials are in place).
  Future<void> _setUpMobileNotifications() async {
    await ref.read(notificationServiceProvider).init();

    try {
      await ref.read(fcmServiceProvider).initialize();
    } catch (e, stackTrace) {
      debugPrint('FCM setup failed (expected without real Firebase credentials): $e\n$stackTrace');
    }

    try {
      final userId = ref.read(authControllerProvider).value?.id;
      if (userId == null) return;
      final documents = await ref.read(documentsRepositoryProvider).fetchForClient(userId);
      await ref.read(notificationServiceProvider).resyncFromServer(documents);
    } catch (e, stackTrace) {
      debugPrint('Reminder resync failed: $e\n$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      destinations: _destinations,
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: switch (_index) {
        0 => const PaymentsScreen(),
        1 => const CalendarScreen(),
        2 => const InfoScreen(),
        _ => const SettingsScreen(),
      },
    );
  }
}
