import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/supabase/supabase_providers.dart';
import '../domain/client.dart';

part 'clients_repository.g.dart';

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
}

@riverpod
ClientsRepository clientsRepository(Ref ref) => ClientsRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<Client>> myClients(Ref ref) => ref.watch(clientsRepositoryProvider).fetchMyClients();
