import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/document_enums.dart';
import '../../../services/supabase/supabase_providers.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

part 'auth_controller.g.dart';

/// Current signed-in user's profile row, kept in sync with Supabase auth
/// state changes (sign in/out/token refresh) and re-fetched from
/// `public.profiles` whenever the session changes.
@riverpod
class AuthController extends _$AuthController {
  @override
  Future<AppUser?> build() async {
    ref.listen(authStateChangesProvider, (_, _) => ref.invalidateSelf());
    return ref.read(authRepositoryProvider).fetchCurrentProfile();
  }

  /// Returns `true` when Supabase requires email confirmation before a
  /// session is issued (no session comes back from signUp in that case) —
  /// the screen uses this to show a "check your inbox" message instead of
  /// silently doing nothing.
  Future<bool> signUpAccountant({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    var needsConfirmation = false;
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(authRepositoryProvider)
          .signUpAccountant(
            email: email,
            password: password,
            fullName: fullName,
            emailRedirectTo: _authRedirectTo,
          );
      needsConfirmation = response.session == null;
      return ref.read(authRepositoryProvider).fetchCurrentProfile();
    });
    return needsConfirmation;
  }

  Future<bool> signUpClient({
    required String email,
    required String password,
    required String fullName,
    required String inviteCode,
  }) async {
    state = const AsyncLoading();
    var needsConfirmation = false;
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(authRepositoryProvider)
          .signUpClient(
            email: email,
            password: password,
            fullName: fullName,
            inviteCode: inviteCode,
            emailRedirectTo: _authRedirectTo,
          );
      needsConfirmation = response.session == null;
      return ref.read(authRepositoryProvider).fetchCurrentProfile();
    });
    return needsConfirmation;
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signIn(email: email, password: password);
      return ref.read(authRepositoryProvider).fetchCurrentProfile();
    });
  }

  /// Opens the Google OAuth browser flow. On success this only creates a
  /// Supabase session — the router sends the user to `/complete-signup` to
  /// provision their `profiles` row (see `resolveRedirect`).
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithGoogle(redirectTo: _authRedirectTo);
      return ref.read(authRepositoryProvider).fetchCurrentProfile();
    });
  }

  /// Same web-origin-vs-custom-scheme split as `password_reset_controller`'s
  /// `_redirectTo` — the PKCE code_verifier lives in *this app's* local
  /// storage, so the callback (Google OAuth or a signup confirmation link)
  /// must reopen this app on mobile, not a browser.
  String get _authRedirectTo =>
      kIsWeb ? '${Uri.base.origin}${Uri.base.path}' : 'muhasebetakip://login-callback';

  Future<void> completeOAuthSignup({
    required UserRole role,
    required String fullName,
    String? inviteCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .completeOAuthSignup(role: role, fullName: fullName, inviteCode: inviteCode);
      return ref.read(authRepositoryProvider).fetchCurrentProfile();
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}
