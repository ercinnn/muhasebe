import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/document_enums.dart';
import '../../../services/supabase/supabase_providers.dart';
import '../../classification/models/extracted_document.dart';
import '../domain/document_record.dart';

part 'documents_repository.g.dart';

const _uuid = Uuid();

class DocumentsRepository {
  DocumentsRepository(this._client);

  final SupabaseClient _client;

  /// Mirrors the `documents_client_id_fis_no_key` unique constraint —
  /// checked up front so the accountant gets a clear warning instead of a
  /// raw constraint-violation error at send time.
  Future<bool> isDuplicateFisNo({required String clientId, required String fisNo}) async {
    final rows = await _client
        .from('documents')
        .select('id')
        .eq('client_id', clientId)
        .eq('fis_no', fisNo)
        .limit(1);
    return rows.isNotEmpty;
  }

  /// Uploads the PDF to the private `documents` bucket at
  /// `{accountantId}/{clientId}/{documentId}.pdf`, then inserts the
  /// matching `documents` row.
  Future<DocumentRecord> uploadAndCreate({
    required String accountantId,
    required String clientId,
    required Uint8List pdfBytes,
    required String rawText,
    required ExtractedDocument extracted,
  }) async {
    final documentId = _uuid.v4();
    final storagePath = '$accountantId/$clientId/$documentId.pdf';

    await _client.storage
        .from('documents')
        .uploadBinary(
          storagePath,
          pdfBytes,
          fileOptions: const FileOptions(contentType: 'application/pdf'),
        );

    final row = await _client
        .from('documents')
        .insert({
          'id': documentId,
          'accountant_id': accountantId,
          'client_id': clientId,
          'category': extracted.category.dbValue,
          'doc_type': extracted.docType.dbValue,
          'period': extracted.period,
          'amount': extracted.amount,
          'due_date': extracted.dueDate?.toIso8601String().split('T').first,
          'fis_no': extracted.fisNo,
          'person_name': extracted.personName,
          'raw_text': rawText,
          'storage_path': storagePath,
          'status': _initialStatus(extracted).dbValue,
        })
        .select()
        .single();

    return DocumentRecord.fromMap(row);
  }

  DocumentStatus _initialStatus(ExtractedDocument extracted) {
    if (extracted.category == DocumentCategory.info) return DocumentStatus.info;
    if (extracted.category == DocumentCategory.payment && extracted.amount == 0) {
      return DocumentStatus.noPayment;
    }
    return DocumentStatus.pending;
  }

  Future<void> markPaid(String documentId) =>
      _client.rpc('mark_document_paid', params: {'p_document_id': documentId});

  Future<void> markSeen(String documentId) =>
      _client.rpc('mark_document_seen', params: {'p_document_id': documentId});

  Future<String> createSignedUrl(String storagePath, {int expiresInSeconds = 3600}) =>
      _client.storage.from('documents').createSignedUrl(storagePath, expiresInSeconds);

  Future<DocumentRecord?> fetchById(String id) async {
    final row = await _client.from('documents').select().eq('id', id).maybeSingle();
    return row == null ? null : DocumentRecord.fromMap(row);
  }

  /// Realtime-backed stream of a client's own documents (RLS already scopes
  /// this to `client_id = auth.uid()`).
  Stream<List<DocumentRecord>> streamForClient(String clientId) => _client
      .from('documents')
      .stream(primaryKey: ['id'])
      .eq('client_id', clientId)
      .order('due_date')
      .map((rows) => rows.map(DocumentRecord.fromMap).toList());

  /// Realtime-backed stream of documents an accountant has sent.
  Stream<List<DocumentRecord>> streamForAccountant(String accountantId) => _client
      .from('documents')
      .stream(primaryKey: ['id'])
      .eq('accountant_id', accountantId)
      .order('created_at', ascending: false)
      .map((rows) => rows.map(DocumentRecord.fromMap).toList());
}

@riverpod
DocumentsRepository documentsRepository(Ref ref) =>
    DocumentsRepository(ref.watch(supabaseClientProvider));

@riverpod
Stream<List<DocumentRecord>> clientDocuments(Ref ref) {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return const Stream.empty();
  return ref.watch(documentsRepositoryProvider).streamForClient(userId);
}

@riverpod
Stream<List<DocumentRecord>> accountantDocuments(Ref ref) {
  final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (userId == null) return const Stream.empty();
  return ref.watch(documentsRepositoryProvider).streamForAccountant(userId);
}

@riverpod
Future<DocumentRecord?> documentById(Ref ref, String id) =>
    ref.watch(documentsRepositoryProvider).fetchById(id);
