import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/document_enums.dart';
import '../../../services/supabase/supabase_providers.dart';
import '../domain/app_user.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;

  /// [emailRedirectTo] follows the same web-origin-vs-custom-scheme split as
  /// [resetPasswordForEmail] — the confirmation link must reopen this app on
  /// mobile (not a browser) for the PKCE code_verifier exchange to work.
  Future<AuthResponse> signUpAccountant({
    required String email,
    required String password,
    required String fullName,
    String? emailRedirectTo,
  }) => _client.auth.signUp(
    email: email,
    password: password,
    emailRedirectTo: emailRedirectTo,
    data: {'role': UserRole.accountant.dbValue, 'full_name': fullName},
  );

  Future<AuthResponse> signUpClient({
    required String email,
    required String password,
    required String fullName,
    required String inviteCode,
    String? emailRedirectTo,
  }) => _client.auth.signUp(
    email: email,
    password: password,
    emailRedirectTo: emailRedirectTo,
    data: {
      'role': UserRole.client.dbValue,
      'full_name': fullName,
      'invite_code': inviteCode,
    },
  );

  Future<void> signIn({required String email, required String password}) =>
      _client.auth.signInWithPassword(email: email, password: password);

  /// [redirectTo] follows the same web-origin-vs-custom-scheme split as
  /// [resetPasswordForEmail] — see `password_reset_controller.dart`.
  Future<void> signInWithGoogle({required String redirectTo}) =>
      _client.auth.signInWithOAuth(OAuthProvider.google, redirectTo: redirectTo);

  /// Provisions the `profiles` row for a user who signed in via Google and
  /// landed with a session but no profile (see `handle_new_user` /
  /// `complete_oauth_signup` in the `20260730140000_google_oauth_signup.sql`
  /// migration).
  Future<void> completeOAuthSignup({
    required UserRole role,
    required String fullName,
    String? inviteCode,
  }) => _client.rpc(
    'complete_oauth_signup',
    params: {
      'p_role': role.dbValue,
      'p_full_name': fullName,
      'p_invite_code': inviteCode,
    },
  );

  Future<void> signOut() => _client.auth.signOut();

  /// [redirectTo] should point at the plain site root (no `#/route`
  /// fragment) — the recovery link's own query/fragment params would
  /// otherwise collide with go_router's hash-based routing. The app
  /// listens for `AuthChangeEvent.passwordRecovery` instead of relying on
  /// landing on a specific route (see `app_router.dart`).
  Future<void> resetPasswordForEmail(String email, {String? redirectTo}) =>
      _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);

  Future<void> updatePassword(String newPassword) =>
      _client.auth.updateUser(UserAttributes(password: newPassword));

  Future<AppUser?> fetchCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return AppUser.fromMap(row);
  }
}

@riverpod
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(supabaseClientProvider));
