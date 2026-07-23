import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  Future<void> signUpAccountant({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signUpAccountant(email: email, password: password, fullName: fullName);
      return ref.read(authRepositoryProvider).fetchCurrentProfile();
    });
  }

  Future<void> signUpClient({
    required String email,
    required String password,
    required String fullName,
    required String inviteCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signUpClient(
            email: email,
            password: password,
            fullName: fullName,
            inviteCode: inviteCode,
          );
      return ref.read(authRepositoryProvider).fetchCurrentProfile();
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signIn(email: email, password: password);
      return ref.read(authRepositoryProvider).fetchCurrentProfile();
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}
