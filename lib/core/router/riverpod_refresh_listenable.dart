import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Bridges a provider's changes into a [Listenable] so go_router's
/// `refreshListenable` re-runs `redirect` on every state change —
/// including an AsyncLoading -> AsyncData transition that happens after
/// the triggering Supabase auth event has already fired.
class RiverpodRefreshListenable<T> extends ChangeNotifier {
  RiverpodRefreshListenable(Ref ref, ProviderListenable<T> provider) {
    ref.listen<T>(provider, (_, _) => notifyListeners());
  }
}
