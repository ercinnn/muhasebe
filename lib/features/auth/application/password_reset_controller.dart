import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';

part 'password_reset_controller.g.dart';

@riverpod
class PasswordResetController extends _$PasswordResetController {
  @override
  FutureOr<void> build() {}

  Future<void> sendResetEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .resetPasswordForEmail(email, redirectTo: _webRedirectTo),
    );
  }

  Future<void> updatePassword(String newPassword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).updatePassword(newPassword),
    );
  }

  /// Mobile has no deep link registered yet, so the recovery link should
  /// fall back to Supabase's configured Site URL there — only build a
  /// redirect on web, and use the current origin so it keeps working after
  /// a domain change with no code edit.
  String? get _webRedirectTo =>
      kIsWeb ? '${Uri.base.origin}${Uri.base.path}' : null;
}
