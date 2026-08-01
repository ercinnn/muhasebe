import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/supabase/supabase_providers.dart';
import '../domain/client.dart';
import '../domain/client_contact_info.dart';
import '../domain/invite.dart';

part 'clients_repository.g.dart';

const _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no O/0/I/1 (readability)
final _codeRandom = Random.secure();

String _generateInviteCode({int length = 8}) =>
    List.generate(length, (_) => _codeAlphabet[_codeRandom.nextInt(_codeAlphabet.length)]).join();

class ClientsRepository {
  ClientsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Client>> fetchMyClients() async {
    final accountantId = _client.auth.currentUser?.id;
    if (accountantId == null) return [];
    final rows = await _client
        .from('profiles')
        .select()
        .eq('accountant_id', accountantId)
        .eq('role', 'client')
        .order('full_name');
    return rows.map(Client.fromMap).toList();
  }

  Future<List<Invite>> fetchMyInvites() async {
    final accountantId = _client.auth.currentUser?.id;
    if (accountantId == null) return [];
    final rows = await _client
        .from('invites')
        .select()
        .eq('accountant_id', accountantId)
        .isFilter('used_at', null)
        .order('created_at', ascending: false);
    return rows.map(Invite.fromMap).toList();
  }

  Future<Invite> createInvite({required String clientName}) async {
    final accountantId = _client.auth.currentUser?.id;
    if (accountantId == null) throw StateError('Oturum bulunamadı');

    // Retry on the rare code collision (unique constraint on invites.code).
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        final row = await _client
            .from('invites')
            .insert({
              'accountant_id': accountantId,
              'code': _generateInviteCode(),
              'client_name': clientName,
            })
            .select()
            .single();
        return Invite.fromMap(row);
      } on PostgrestException catch (e) {
        if (e.code != '23505' || attempt == 4) rethrow;
      }
    }
    throw StateError('Davet kodu oluşturulamadı');
  }

  Future<ClientContactInfo?> fetchContactInfo(String clientId) async {
    final row = await _client
        .from('client_contact_info')
        .select()
        .eq('client_id', clientId)
        .maybeSingle();
    return row == null ? null : ClientContactInfo.fromMap(row);
  }

  Future<void> saveContactInfo(ClientContactInfo info) async {
    final accountantId = _client.auth.currentUser?.id;
    if (accountantId == null) throw StateError('Oturum bulunamadı');
    await _client.from('client_contact_info').upsert({
      'client_id': info.clientId,
      'accountant_id': accountantId,
      'phone': info.phone,
      'address': info.address,
      'notes': info.notes,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

@riverpod
ClientsRepository clientsRepository(Ref ref) => ClientsRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<Client>> myClients(Ref ref) => ref.watch(clientsRepositoryProvider).fetchMyClients();

@riverpod
Future<List<Invite>> myInvites(Ref ref) => ref.watch(clientsRepositoryProvider).fetchMyInvites();

@riverpod
Future<ClientContactInfo?> clientContactInfo(Ref ref, String clientId) =>
    ref.watch(clientsRepositoryProvider).fetchContactInfo(clientId);
