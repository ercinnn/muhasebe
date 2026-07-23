/// Mirrors the `documents.category` check constraint in
/// supabase/migrations/20260723200846_init.sql.
enum DocumentCategory {
  payment('payment'),
  info('info'),
  unclassified('unclassified');

  const DocumentCategory(this.dbValue);
  final String dbValue;

  static DocumentCategory fromDb(String value) =>
      values.firstWhere((e) => e.dbValue == value);

  String get label => switch (this) {
    DocumentCategory.payment => 'Ödeme',
    DocumentCategory.info => 'Bilgilendirme',
    DocumentCategory.unclassified => 'Sınıflandırılamadı',
  };
}

/// Mirrors the `documents.doc_type` check constraint.
enum DocType {
  kdv('kdv'),
  muhtasar('muhtasar'),
  kdv2('kdv2'),
  geciciVergi('gecici_vergi'),
  damga('damga'),
  sgkPrim('sgk_prim'),
  iseGiris('ise_giris'),
  istenCikis('isten_cikis'),
  other('other');

  const DocType(this.dbValue);
  final String dbValue;

  static DocType fromDb(String value) =>
      values.firstWhere((e) => e.dbValue == value);

  String get label => switch (this) {
    DocType.kdv => 'KDV',
    DocType.muhtasar => 'Muhtasar',
    DocType.kdv2 => 'KDV Tevkifatı',
    DocType.geciciVergi => 'Geçici Vergi',
    DocType.damga => 'Damga Vergisi',
    DocType.sgkPrim => 'SGK Prim',
    DocType.iseGiris => 'İşe Giriş Bildirgesi',
    DocType.istenCikis => 'İşten Ayrılış Bildirgesi',
    DocType.other => 'Diğer',
  };
}

/// Mirrors the `documents.status` check constraint.
enum DocumentStatus {
  pending('pending'),
  paid('paid'),
  noPayment('no_payment'),
  info('info');

  const DocumentStatus(this.dbValue);
  final String dbValue;

  static DocumentStatus fromDb(String value) =>
      values.firstWhere((e) => e.dbValue == value);

  String get label => switch (this) {
    DocumentStatus.pending => 'Bekliyor',
    DocumentStatus.paid => 'Ödendi',
    DocumentStatus.noPayment => 'Ödeme gerekmez',
    DocumentStatus.info => 'Bilgilendirme',
  };
}

/// Mirrors the `profiles.role` check constraint.
enum UserRole {
  accountant('accountant'),
  client('client');

  const UserRole(this.dbValue);
  final String dbValue;

  static UserRole fromDb(String value) =>
      values.firstWhere((e) => e.dbValue == value);
}
