import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';

/// A client (mükellef) profile as seen by their accountant.
@freezed
abstract class Client with _$Client {
  const factory Client({required String id, required String fullName}) = _Client;

  factory Client.fromMap(Map<String, dynamic> map) =>
      Client(id: map['id'] as String, fullName: map['full_name'] as String);
}
