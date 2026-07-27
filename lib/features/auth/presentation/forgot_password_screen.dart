import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/password_reset_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(passwordResetControllerProvider.notifier)
        .sendResetEmail(_emailController.text.trim());
    if (mounted && !ref.read(passwordResetControllerProvider).hasError) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(passwordResetControllerProvider);

    ref.listen(passwordResetControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: ${next.error}')),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _sent ? _buildSentMessage(context) : _buildForm(context, resetState),
          ),
        ),
      ),
    );
  }

  Widget _buildSentMessage(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('E-posta gönderildi', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Text(
          'Şifre sıfırlama bağlantısını içeren e-postayı gelen kutunuzda '
          '(veya spam klasöründe) bulabilirsiniz.',
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Giriş ekranına dön'),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, AsyncValue<void> resetState) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Şifremi Unuttum', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text('Hesabınıza kayıtlı e-posta adresini girin, size bir sıfırlama '
              'bağlantısı gönderelim.'),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-posta'),
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Geçerli bir e-posta girin' : null,
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
                : const Text('Sıfırlama Bağlantısı Gönder'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Giriş ekranına dön'),
          ),
        ],
      ),
    );
  }
}
