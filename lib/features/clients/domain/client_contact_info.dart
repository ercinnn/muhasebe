import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_contact_info.freezed.dart';

/// An accountant's own notes about a client — phone/address/notes fields
/// the app never collects from the client themselves (see
/// `client_contact_info` table).
@freezed
abstract class ClientContactInfo with _$ClientContactInfo {
  const factory ClientContactInfo({
    required String clientId,
    String? phone,
    String? address,
    String? notes,
  }) = _ClientContactInfo;

  factory ClientContactInfo.fromMap(Map<String, dynamic> map) => ClientContactInfo(
    clientId: map['client_id'] as String,
    phone: map['phone'] as String?,
    address: map['address'] as String?,
    notes: map['notes'] as String?,
  );
}
