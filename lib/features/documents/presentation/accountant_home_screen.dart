import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../auth/application/auth_controller.dart';
import '../../clients/presentation/clients_screen.dart';
import '../../upload/presentation/upload_screen.dart';
import 'accountant/sent_documents_screen.dart';

/// Shell for the accountant role: Mükelleflerim / Belge Yükle / Gönderilenler.
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
    return AdaptiveScaffold(
      destinations: _destinations,
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(_titles[_index]),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: GradientScaffoldBackground(
        child: switch (_index) {
          0 => const ClientsScreen(),
          1 => const UploadScreen(),
          _ => const SentDocumentsScreen(),
        },
      ),
    );
  }
}
