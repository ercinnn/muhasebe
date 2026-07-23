import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/constants/document_enums.dart';

part 'document_record.freezed.dart';

/// A row from `public.documents`, as read back for display. Intentionally
/// excludes `raw_text` — the read paths (lists, detail screens) never need
/// it, which keeps it out of memory/logs beyond the write path that needs it.
@freezed
abstract class DocumentRecord with _$DocumentRecord {
  const factory DocumentRecord({
    required String id,
    required DateTime createdAt,
    required String accountantId,
    required String clientId,
    required DocumentCategory category,
    required DocType docType,
    String? period,
    double? amount,
    DateTime? dueDate,
    String? fisNo,
    String? personName,
    required String storagePath,
    required DocumentStatus status,
    DateTime? paidAt,
    DateTime? seenAt,
  }) = _DocumentRecord;

  factory DocumentRecord.fromMap(Map<String, dynamic> map) => DocumentRecord(
    id: map['id'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
    accountantId: map['accountant_id'] as String,
    clientId: map['client_id'] as String,
    category: DocumentCategory.fromDb(map['category'] as String),
    docType: DocType.fromDb(map['doc_type'] as String),
    period: map['period'] as String?,
    amount: (map['amount'] as num?)?.toDouble(),
    dueDate: map['due_date'] == null ? null : DateTime.parse(map['due_date'] as String),
    fisNo: map['fis_no'] as String?,
    personName: map['person_name'] as String?,
    storagePath: map['storage_path'] as String,
    status: DocumentStatus.fromDb(map['status'] as String),
    paidAt: map['paid_at'] == null ? null : DateTime.parse(map['paid_at'] as String),
    seenAt: map['seen_at'] == null ? null : DateTime.parse(map['seen_at'] as String),
  );
}
