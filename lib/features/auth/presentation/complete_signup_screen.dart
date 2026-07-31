import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/document_enums.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_background.dart';
import '../application/auth_controller.dart';

/// Shown after a Google sign-in that landed with a Supabase session but no
/// `profiles` row yet (see `resolveRedirect` in `app_router.dart` and the
/// `complete_oauth_signup` RPC). Collects the same information the
/// email/password [SignupScreen] does, then provisions the profile.
class CompleteSignupScreen extends ConsumerStatefulWidget {
  const CompleteSignupScreen({super.key});

  @override
  ConsumerState<CompleteSignupScreen> createState() => _CompleteSignupScreenState();
}

class _CompleteSignupScreenState extends ConsumerState<CompleteSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _fullNameController = TextEditingController(text: _googleFullName);
  final _inviteCodeController = TextEditingController();
  UserRole _role = UserRole.accountant;

  String get _googleFullName {
    final metadata = Supabase.instance.client.auth.currentUser?.userMetadata;
    return (metadata?['full_name'] ?? metadata?['name'] ?? '') as String;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .completeOAuthSignup(
          role: _role,
          fullName: _fullNameController.text.trim(),
          inviteCode: _role == UserRole.client ? _inviteCodeController.text.trim() : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final email = Supabase.instance.client.auth.currentUser?.email;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt tamamlanamadı: ${next.error}')),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientScaffoldBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Hesabınızı Tamamlayın', style: Theme.of(context).textTheme.headlineSmall),
                      if (email != null) ...[
                        const SizedBox(height: 8),
                        Text(email, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 24),
                      SegmentedButton<UserRole>(
                        segments: const [
                          ButtonSegment(value: UserRole.accountant, label: Text('Muhasebeci')),
                          ButtonSegment(value: UserRole.client, label: Text('Mükellef')),
                        ],
                        selected: {_role},
                        onSelectionChanged: (s) => setState(() => _role = s.first),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(labelText: 'Ad Soyad / Unvan'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null,
                      ),
                      if (_role == UserRole.client) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _inviteCodeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(labelText: 'Davet Kodu'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Davet kodu zorunlu' : null,
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: authState.isLoading ? null : _submit,
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Devam Et'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () => ref.read(authControllerProvider.notifier).signOut(),
                        child: const Text('Farklı bir hesapla devam et (çıkış yap)'),
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
