import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/role_shell_scaffold.dart';
import '../../../services/notifications/notification_providers.dart';
import '../../../services/push/fcm_service.dart';
import '../../auth/application/auth_controller.dart';
import '../../settings/presentation/settings_screen.dart';
import '../application/inbox_summary.dart';
import '../data/documents_repository.dart';
import 'client/calendar_screen.dart';
import 'client/info_screen.dart';
import 'client/paid_documents_screen.dart';
import 'client/payments_screen.dart';

/// Shell for the client role: Ödemeler / Ödenenler / Takvim / Bilgilendirme /
/// Ayarlar.
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
    AdaptiveDestination(icon: Icons.check_circle_outline, label: 'Ödenenler'),
    AdaptiveDestination(icon: Icons.calendar_month_outlined, label: 'Takvim'),
    AdaptiveDestination(icon: Icons.info_outline, label: 'Bilgilendirme'),
    AdaptiveDestination(icon: Icons.settings_outlined, label: 'Ayarlar'),
  ];

  static const _titles = ['Ödemeler', 'Ödenenler', 'Takvim', 'Bilgilendirme', 'Ayarlar'];

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
      debugPrint('FCM setup failed: $e\n$stackTrace');
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
    final unreadCount = ref.watch(inboxSummaryProvider).unreadCount;

    return RoleShellScaffold(
      destinations: _destinations,
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      title: _titles[_index],
      onLogout: () => ref.read(authControllerProvider.notifier).signOut(),
      appBarActions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text('$unreadCount'),
            child: const Icon(Icons.mail_outline),
          ),
        ),
      ],
      body: switch (_index) {
        0 => const PaymentsScreen(),
        1 => const PaidDocumentsScreen(),
        2 => const CalendarScreen(),
        3 => const InfoScreen(),
        _ => const SettingsScreen(),
      },
    );
  }
}
