import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../services/pdf/pdf_processing_service.dart';
import '../../../services/supabase/supabase_providers.dart';
import '../../classification/models/extracted_document.dart';
import '../../classification/parsing/tr_number_parser.dart';
import '../../clients/data/clients_repository.dart';
import '../../documents/data/documents_repository.dart';
import '../domain/upload_draft.dart';

part 'upload_controller.g.dart';

const _uuid = Uuid();

typedef PickedPdfFile = ({String name, Uint8List bytes});

@riverpod
class UploadController extends _$UploadController {
  @override
  List<UploadDraft> build() => [];

  Future<void> addFiles(List<PickedPdfFile> files) async {
    for (final file in files) {
      final draft = UploadDraft(
        id: _uuid.v4(),
        fileName: file.name,
        fileBytes: file.bytes,
        status: UploadDraftStatus.parsing,
      );
      state = [...state, draft];
      unawaited(_process(draft.id));
    }
  }

  Future<void> _process(String draftId) async {
    final draft = state.firstWhere((d) => d.id == draftId);
    try {
      final result = await ref
          .read(pdfProcessingServiceProvider)
          .process(draft.fileBytes, sourceName: draft.fileName);
      _update(
        draftId,
        (d) => d.copyWith(
          status: UploadDraftStatus.needsReview,
          rawText: result.rawText,
          extracted: result.document,
          usedOcr: result.usedOcr,
        ),
      );
      await _suggestClientByName(draftId);
    } catch (e) {
      _update(
        draftId,
        (d) => d.copyWith(status: UploadDraftStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Suggests a client when the extracted person/title name matches one of
  /// the accountant's clients (case-insensitive, either direction contains).
  Future<void> _suggestClientByName(String draftId) async {
    final draft = state.firstWhere((d) => d.id == draftId);
    final name = draft.extracted?.personName;
    if (name == null) return;

    final clients = await ref.read(myClientsProvider.future);
    final normalized = name.trim().toLowerCase();
    for (final client in clients) {
      final clientName = client.fullName.trim().toLowerCase();
      if (clientName.isEmpty) continue;
      if (normalized.contains(clientName) || clientName.contains(normalized)) {
        selectClient(draftId, client.id);
        return;
      }
    }
  }

  void selectClient(String draftId, String? clientId) {
    _update(draftId, (d) => d.copyWith(selectedClientId: clientId));
    unawaited(_checkDuplicate(draftId));
  }

  Future<void> _checkDuplicate(String draftId) async {
    final draft = state.firstWhere((d) => d.id == draftId);
    final clientId = draft.selectedClientId;
    final fisNo = draft.extracted?.fisNo;
    if (clientId == null || fisNo == null) {
      _update(draftId, (d) => d.copyWith(isDuplicate: false));
      return;
    }
    final isDuplicate = await ref
        .read(documentsRepositoryProvider)
        .isDuplicateFisNo(clientId: clientId, fisNo: fisNo);
    _update(draftId, (d) => d.copyWith(isDuplicate: isDuplicate));
  }

  void updateExtracted(String draftId, ExtractedDocument Function(ExtractedDocument) update) {
    _update(draftId, (d) {
      final current = d.extracted;
      if (current == null) return d;
      return d.copyWith(extracted: update(current));
    });
    unawaited(_checkDuplicate(draftId));
  }

  /// Parses the accountant's raw "Tutar (₺)" field input (Turkish decimal
  /// comma format) and stores the result — keeps the classification
  /// package's number-parsing format as an implementation detail the
  /// presentation layer doesn't need to know about.
  void updateAmountFromInput(String draftId, String rawValue) {
    updateExtracted(draftId, (e) => e.copyWith(amount: parseTurkishNumber(rawValue)));
  }

  Future<void> send(String draftId) async {
    final draft = state.firstWhere((d) => d.id == draftId);
    final extracted = draft.extracted;
    final clientId = draft.selectedClientId;
    if (extracted == null || clientId == null) return;

    final accountantId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (accountantId == null) return;

    _update(draftId, (d) => d.copyWith(status: UploadDraftStatus.sending));
    try {
      await ref
          .read(documentsRepositoryProvider)
          .uploadAndCreate(
            accountantId: accountantId,
            clientId: clientId,
            pdfBytes: draft.fileBytes,
            rawText: draft.rawText ?? '',
            extracted: extracted,
          );
      _update(draftId, (d) => d.copyWith(status: UploadDraftStatus.sent));
    } catch (e) {
      _update(
        draftId,
        (d) => d.copyWith(status: UploadDraftStatus.needsReview, errorMessage: e.toString()),
      );
    }
  }

  void removeDraft(String draftId) {
    state = state.where((d) => d.id != draftId).toList();
  }

  void _update(String draftId, UploadDraft Function(UploadDraft) update) {
    state = [
      for (final d in state)
        if (d.id == draftId) update(d) else d,
    ];
  }
}
