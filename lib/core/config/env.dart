/// Compile-time config, supplied via `--dart-define-from-file=env/dev.json`
/// (see env/dev.example.json for the expected keys).
class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static void assertConfigured() {
    if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY tanımlı değil. Uygulamayı '
        '--dart-define-from-file=env/dev.json ile çalıştırın.',
      );
    }
  }
}
