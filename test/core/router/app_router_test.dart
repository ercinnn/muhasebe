import 'package:flutter_test/flutter_test.dart';
import 'package:muhasebe_takip/core/constants/document_enums.dart';
import 'package:muhasebe_takip/core/router/app_router.dart';
import 'package:muhasebe_takip/features/auth/domain/app_user.dart';

const _accountant = AppUser(id: 'acc-1', role: UserRole.accountant, fullName: 'Muhasebeci');
const _client = AppUser(id: 'client-1', role: UserRole.client, fullName: 'Mükellef');

void main() {
  group('resolveRedirect', () {
    test('never redirects away from /reset-password, even mid-auth-load', () {
      expect(
        resolveRedirect(matchedLocation: '/reset-password', isLoading: true, user: null),
        isNull,
      );
      expect(
        resolveRedirect(matchedLocation: '/reset-password', isLoading: false, user: _client),
        isNull,
      );
    });

    test('does nothing while auth state is still loading (except reset-password)', () {
      expect(resolveRedirect(matchedLocation: '/login', isLoading: true, user: null), isNull);
      expect(resolveRedirect(matchedLocation: '/accountant', isLoading: true, user: null), isNull);
    });

    test('logged out: sends non-auth routes to /login, leaves auth routes alone', () {
      expect(resolveRedirect(matchedLocation: '/client', isLoading: false, user: null), '/login');
      expect(
        resolveRedirect(matchedLocation: '/login', isLoading: false, user: null),
        isNull,
      );
      expect(
        resolveRedirect(matchedLocation: '/signup', isLoading: false, user: null),
        isNull,
      );
      expect(
        resolveRedirect(matchedLocation: '/forgot-password', isLoading: false, user: null),
        isNull,
      );
    });

    test('logged in accountant visiting an auth page is sent to /accountant', () {
      expect(
        resolveRedirect(matchedLocation: '/login', isLoading: false, user: _accountant),
        '/accountant',
      );
    });

    test('logged in client visiting an auth page is sent to /client', () {
      expect(
        resolveRedirect(matchedLocation: '/signup', isLoading: false, user: _client),
        '/client',
      );
    });

    test('accountant on a /client* route is bounced back to /accountant', () {
      expect(
        resolveRedirect(matchedLocation: '/client', isLoading: false, user: _accountant),
        '/accountant',
      );
    });

    test('client on an /accountant* route is bounced back to /client', () {
      expect(
        resolveRedirect(matchedLocation: '/accountant', isLoading: false, user: _client),
        '/client',
      );
    });

    test('logged in user on their own role home or a shared route is left alone', () {
      expect(
        resolveRedirect(matchedLocation: '/accountant', isLoading: false, user: _accountant),
        isNull,
      );
      expect(
        resolveRedirect(matchedLocation: '/client', isLoading: false, user: _client),
        isNull,
      );
      expect(
        resolveRedirect(matchedLocation: '/document/abc-123', isLoading: false, user: _client),
        isNull,
      );
    });
  });
}
