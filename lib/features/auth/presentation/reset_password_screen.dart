import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_background.dart';
import '../application/password_reset_controller.dart';
import '../domain/password_policy.dart';

/// Reached only via the `AuthChangeEvent.passwordRecovery` redirect set up
/// in `app_router.dart` — the recovery session it needs is already active
/// by the time this screen builds.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(passwordResetControllerProvider.notifier)
        .updatePassword(_passwordController.text);
    final state = ref.read(passwordResetControllerProvider);
    if (mounted && !state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifreniz güncellendi.')),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(passwordResetControllerProvider);

    ref.listen(passwordResetControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şifre güncellenemedi: ${next.error}')),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientScaffoldBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Yeni Şifre Belirle', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Yeni şifre',
                          helperText: 'En az 8 karakter, 1 büyük harf, 1 küçük harf, 1 rakam',
                          helperMaxLines: 2,
                        ),
                        validator: validatePasswordStrength,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Yeni şifre (tekrar)'),
                        validator: (v) =>
                            (v != _passwordController.text) ? 'Şifreler eşleşmiyor' : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: resetState.isLoading ? null : _submit,
                        child: resetState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Şifreyi Güncelle'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
