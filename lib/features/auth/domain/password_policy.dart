/// Mirrors the Supabase Auth password policy (`minimum_password_length` +
/// `password_requirements = lower_upper_letters_digits` in
/// `supabase/config.toml` / the hosted project's Auth settings) so weak
/// passwords are rejected client-side instead of round-tripping to the server.
String? validatePasswordStrength(String? value) {
  final password = value ?? '';
  if (password.length < 8) return 'Şifre en az 8 karakter olmalı';
  if (!password.contains(RegExp(r'[a-z]'))) return 'Şifre en az 1 küçük harf içermeli';
  if (!password.contains(RegExp(r'[A-Z]'))) return 'Şifre en az 1 büyük harf içermeli';
  if (!password.contains(RegExp(r'[0-9]'))) return 'Şifre en az 1 rakam içermeli';
  return null;
}
