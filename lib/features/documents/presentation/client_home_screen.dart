import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/adaptive_scaffold.dart';
import '../../auth/application/auth_controller.dart';

/// Placeholder shell for the client role. Real tab content
/// (Ödemeler / Takvim / Bilgilendirme) lands in Faz 5.
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
    final user = ref.watch(authControllerProvider).value;

    return AdaptiveScaffold(
      destinations: _destinations,
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      appBar: AppBar(title: Text(_titles[_index])),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hoş geldiniz, ${user?.fullName ?? ''}'),
            const SizedBox(height: 8),
            const Text('Mükellef paneli (yakında)'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
              child: const Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
