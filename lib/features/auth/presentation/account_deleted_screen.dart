import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_background.dart';
import '../application/auth_controller.dart';

/// Reached via `resolveRedirect` when the signed-in profile has
/// `deleted_at` set. Unlike [AccountFrozenScreen] there is no way back —
/// the only action is signing out. This mainly covers a second
/// still-signed-in session/device; the device that requested the deletion
/// is signed out immediately by `AuthController.deleteAccount`.
class AccountDeletedScreen extends ConsumerWidget {
  const AccountDeletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientScaffoldBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.block_outlined, size: 48, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Hesabınız Silindi', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    const Text(
                      'Bu hesap kalıcı olarak silindi ve artık kullanılamıyor.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                      child: const Text('Çıkış Yap'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
