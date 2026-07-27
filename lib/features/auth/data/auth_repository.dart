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

  Future<void> signUpAccountant({
    required String email,
    required String password,
    required String fullName,
  }) => _client.auth.signUp(
    email: email,
    password: password,
    data: {'role': UserRole.accountant.dbValue, 'full_name': fullName},
  );

  Future<void> signUpClient({
    required String email,
    required String password,
    required String fullName,
    required String inviteCode,
  }) => _client.auth.signUp(
    email: email,
    password: password,
    data: {
      'role': UserRole.client.dbValue,
      'full_name': fullName,
      'invite_code': inviteCode,
    },
  );

  Future<void> signIn({required String email, required String password}) =>
      _client.auth.signInWithPassword(email: email, password: password);

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
