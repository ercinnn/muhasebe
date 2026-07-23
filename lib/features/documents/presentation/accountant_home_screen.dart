import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/adaptive_scaffold.dart';
import '../../auth/application/auth_controller.dart';

/// Placeholder shell for the accountant role. Real tab content
/// (Mükelleflerim / Belge Yükle / Gönderilenler) lands in Faz 4-5.
class AccountantHomeScreen extends ConsumerStatefulWidget {
  const AccountantHomeScreen({super.key});

  @override
  ConsumerState<AccountantHomeScreen> createState() => _AccountantHomeScreenState();
}

class _AccountantHomeScreenState extends ConsumerState<AccountantHomeScreen> {
  int _index = 0;

  static const _destinations = [
    AdaptiveDestination(icon: Icons.people_outline, label: 'Mükelleflerim'),
    AdaptiveDestination(icon: Icons.upload_file_outlined, label: 'Belge Yükle'),
    AdaptiveDestination(icon: Icons.send_outlined, label: 'Gönderilenler'),
  ];

  static const _titles = ['Mükelleflerim', 'Belge Yükle', 'Gönderilenler'];

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
            const Text('Muhasebeci paneli (yakında)'),
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
