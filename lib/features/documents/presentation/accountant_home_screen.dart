import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/role_shell_scaffold.dart';
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
    return RoleShellScaffold(
      destinations: _destinations,
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      title: _titles[_index],
      onLogout: () => ref.read(authControllerProvider.notifier).signOut(),
      body: switch (_index) {
        0 => const ClientsScreen(),
        1 => const UploadScreen(),
        _ => const SentDocumentsScreen(),
      },
    );
  }
}
