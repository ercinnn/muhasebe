import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite.freezed.dart';

@freezed
abstract class Invite with _$Invite {
  const factory Invite({
    required String id,
    required String code,
    required String clientName,
    DateTime? usedAt,
  }) = _Invite;

  factory Invite.fromMap(Map<String, dynamic> map) => Invite(
    id: map['id'] as String,
    code: map['code'] as String,
    clientName: map['client_name'] as String,
    usedAt: map['used_at'] == null ? null : DateTime.parse(map['used_at'] as String),
  );
}
