import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_background.dart';
import '../application/auth_controller.dart';

/// Reached via `resolveRedirect` whenever the signed-in profile has
/// `frozen_at` set (see the account-management RPCs) — the only two ways
/// out are reactivating or signing out.
class AccountFrozenScreen extends ConsumerWidget {
  const AccountFrozenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('İşlem başarısız: ${next.error}')));
      }
    });

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
                    Icon(Icons.pause_circle_outline, size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('Hesabınız Donduruldu', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    const Text(
                      'Hesabınızı dondurduğunuz için giriş yapamıyorsunuz. '
                      'Devam etmek için hesabınızı yeniden aktifleştirebilir '
                      'ya da çıkış yapabilirsiniz.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => ref.read(authControllerProvider.notifier).unfreezeAccount(),
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Hesabımı Yeniden Aktifleştir'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => ref.read(authControllerProvider.notifier).signOut(),
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
