import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/documents/presentation/accountant_home_screen.dart';
import '../../features/documents/presentation/client_home_screen.dart';
import '../constants/document_enums.dart';
import 'riverpod_refresh_listenable.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: RiverpodRefreshListenable(ref, authControllerProvider),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      if (authState.isLoading) return null;

      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
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
      GoRoute(path: '/accountant', builder: (context, state) => const AccountantHomeScreen()),
      GoRoute(path: '/client', builder: (context, state) => const ClientHomeScreen()),
    ],
  );
}
