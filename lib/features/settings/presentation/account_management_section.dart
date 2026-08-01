import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/document_enums.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../services/notifications/notification_providers.dart';
import '../../auth/application/auth_controller.dart';

/// "Hesap Yönetimi" card shared by both roles' Ayarlar screens: freeze
/// (temporary, reversible login block) and delete (permanent, anonymizes
/// the profile — see `20260731150000_account_freeze_delete.sql`).
class AccountManagementSection extends ConsumerWidget {
  const AccountManagementSection({super.key});

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _freeze(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: 'Hesabı Dondur',
      message:
          'Hesabınızı dondurmak istediğinizden emin misiniz? Yeniden giriş '
          'yapana kadar hesabınız kullanılamaz; dilediğinizde tekrar '
          'aktifleştirebilirsiniz.',
      confirmLabel: 'Dondur',
    );
    if (confirmed) {
      await ref.read(authControllerProvider.notifier).freezeAccount();
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: 'Hesabı Sil',
      message:
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri '
          'alınamaz ve hesabınıza bir daha giriş yapamazsınız.',
      confirmLabel: 'Kalıcı Olarak Sil',
      destructive: true,
    );
    if (!confirmed) return;

    // Local reminder alarms only exist for the client role, and only on
    // mobile — best-effort, must not block the actual account deletion if
    // the notification plugin was never initialized (e.g. accountant role).
    if (!kIsWeb && ref.read(authControllerProvider).value?.role == UserRole.client) {
      try {
        await ref.read(notificationServiceProvider).resyncFromServer(const []);
      } catch (e, stackTrace) {
        debugPrint('Reminder cleanup on account deletion failed: $e\n$stackTrace');
      }
    }
    await ref.read(authControllerProvider.notifier).deleteAccount();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.pause_circle_outline),
            title: const Text('Hesabımı Dondur'),
            subtitle: const Text('Geçici ve geri alınabilir'),
            onTap: () => _freeze(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Hesabımı Sil',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('Kalıcıdır, geri alınamaz'),
            onTap: () => _delete(context, ref),
          ),
        ],
      ),
    );
  }
}
