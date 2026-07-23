import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/constants/document_enums.dart';

part 'app_user.freezed.dart';

/// Mirrors a row in `public.profiles`.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required UserRole role,
    required String fullName,
    String? accountantId,
  }) = _AppUser;

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    id: map['id'] as String,
    role: UserRole.fromDb(map['role'] as String),
    fullName: map['full_name'] as String,
    accountantId: map['accountant_id'] as String?,
  );
}
