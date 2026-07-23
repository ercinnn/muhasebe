import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/adaptive_scaffold.dart';
import '../../auth/application/auth_controller.dart';
import 'client/calendar_screen.dart';
import 'client/info_screen.dart';
import 'client/payments_screen.dart';

/// Shell for the client role: Ödemeler / Takvim / Bilgilendirme.
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
  ];

  static const _titles = ['Ödemeler', 'Takvim', 'Bilgilendirme'];

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
        _ => const InfoScreen(),
      },
    );
  }
}
