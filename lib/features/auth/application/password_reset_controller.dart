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
          .resetPasswordForEmail(email, redirectTo: _redirectTo),
    );
  }

  Future<void> updatePassword(String newPassword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).updatePassword(newPassword),
    );
  }

  /// Web: current origin, so it keeps working after a domain change with no
  /// code edit. Mobile: a custom URL scheme (see AndroidManifest.xml /
  /// Info.plist `muhasebetakip://`) rather than the site's https URL — the
  /// PKCE code_verifier this exchange needs is stored in *this app's* local
  /// storage, so the link must reopen this app, not a browser, or the
  /// exchange fails with "Code verifier could not be found".
  String get _redirectTo =>
      kIsWeb ? '${Uri.base.origin}${Uri.base.path}' : 'muhasebetakip://reset-password';
}
