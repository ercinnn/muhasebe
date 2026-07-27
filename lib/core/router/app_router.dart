import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/documents/presentation/accountant_home_screen.dart';
import '../../features/documents/presentation/client_home_screen.dart';
import '../../features/documents/presentation/document_detail_screen.dart';
import '../../services/supabase/supabase_providers.dart';
import '../constants/document_enums.dart';
import 'riverpod_refresh_listenable.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: RiverpodRefreshListenable(ref, authControllerProvider),
    redirect: (context, state) {
      // Always reachable: the recovery session that lands here still counts
      // as "logged in" to the checks below, which would otherwise bounce it
      // to a role home before the user gets to set a new password.
      if (state.matchedLocation == '/reset-password') return null;

      final authState = ref.read(authControllerProvider);
      if (authState.isLoading) return null;

      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';
      final user = authState.value;

      if (user == null) {
        return loggingIn ? null : '/login';
      }

      final roleHome = user.role == UserRole.accountant ? '/accountant' : '/client';
      if (loggingIn) return roleHome;

      final onWrongRole =
          (user.role == UserRole.accountant && state.matchedLocation.startsWith('/client')) ||
          (user.role == UserRole.client && state.matchedLocation.startsWith('/accountant'));
      if (onWrongRole) return roleHome;

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(path: '/accountant', builder: (context, state) => const AccountantHomeScreen()),
      GoRoute(path: '/client', builder: (context, state) => const ClientHomeScreen()),
      GoRoute(
        path: '/document/:id',
        builder: (context, state) =>
            DocumentDetailScreen(documentId: state.pathParameters['id']!),
      ),
    ],
  );

  // The recovery link intentionally redirects to the site root (see
  // `password_reset_controller.dart`) rather than a `#/reset-password`
  // fragment, to avoid colliding with go_router's own hash-based routing.
  // So instead of landing on the right route by URL, catch the one-time
  // `AuthChangeEvent.passwordRecovery` GoTrue fires once it parses the
  // recovery token and navigate explicitly.
  ref.listen(authStateChangesProvider, (previous, next) {
    if (next.value?.event == AuthChangeEvent.passwordRecovery) {
      router.go('/reset-password');
    }
  });

  return router;
}
