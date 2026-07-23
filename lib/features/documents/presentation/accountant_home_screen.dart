import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/adaptive_scaffold.dart';
import '../../auth/application/auth_controller.dart';
import '../../upload/presentation/upload_screen.dart';

/// Shell for the accountant role. "Belge Yükle" is wired to the real
/// upload flow (Faz 4); "Mükelleflerim" / "Gönderilenler" are still
/// placeholders, built out in Faz 5.
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
      body: switch (_index) {
        1 => const UploadScreen(),
        _ => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hoş geldiniz, ${user?.fullName ?? ''}'),
              const SizedBox(height: 8),
              const Text('Bu sekme Faz 5\'te tamamlanacak'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                child: const Text('Çıkış Yap'),
              ),
            ],
          ),
        ),
      },
    );
  }
}
