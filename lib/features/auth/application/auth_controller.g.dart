// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Current signed-in user's profile row, kept in sync with Supabase auth
/// state changes (sign in/out/token refresh) and re-fetched from
/// `public.profiles` whenever the session changes.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Current signed-in user's profile row, kept in sync with Supabase auth
/// state changes (sign in/out/token refresh) and re-fetched from
/// `public.profiles` whenever the session changes.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, AppUser?> {
  /// Current signed-in user's profile row, kept in sync with Supabase auth
  /// state changes (sign in/out/token refresh) and re-fetched from
  /// `public.profiles` whenever the session changes.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'e36a2b44e7d064abc264789c070f14b5f5ee17a5';

/// Current signed-in user's profile row, kept in sync with Supabase auth
/// state changes (sign in/out/token refresh) and re-fetched from
/// `public.profiles` whenever the session changes.

abstract class _$AuthController extends $AsyncNotifier<AppUser?> {
  FutureOr<AppUser?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppUser?>, AppUser?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppUser?>, AppUser?>,
              AsyncValue<AppUser?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
