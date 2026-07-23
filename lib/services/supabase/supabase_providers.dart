import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

@riverpod
GoTrueClient auth(Ref ref) => ref.watch(supabaseClientProvider).auth;

/// Emits on every auth state change (sign in/out/token refresh) so the
/// router and other providers can react to session changes.
@riverpod
Stream<AuthState> authStateChanges(Ref ref) =>
    ref.watch(authProvider).onAuthStateChange;
