import '../../core/constants/document_enums.dart';

/// Parses the data-only FCM payload sent by the on-document-insert Edge
/// Function. Carries just enough to schedule a local reminder without a
/// network round-trip — important for the background isolate handler,
/// which has no app/Riverpod state to fall back on.
class PushPayload {
  const PushPayload({
    required this.documentId,
    required this.dueDate,
    required this.docType,
    this.amount,
  });

  final String documentId;
  final DateTime dueDate;
  final DocType docType;
  final double? amount;

  static PushPayload? fromData(Map<String, dynamic> data) {
    if (data['type'] != 'new_document') return null;

    final documentId = data['document_id'] as String?;
    final dueDateRaw = data['due_date'] as String?;
    final docTypeRaw = data['doc_type'] as String?;
    if (documentId == null || dueDateRaw == null || docTypeRaw == null) return null;

    final dueDate = DateTime.tryParse(dueDateRaw);
    if (dueDate == null) return null;

    final DocType docType;
    try {
      docType = DocType.fromDb(docTypeRaw);
    } on StateError {
      return null;
    }

    final amountRaw = data['amount'];
    final amount = amountRaw == null ? null : double.tryParse(amountRaw.toString());

    return PushPayload(documentId: documentId, dueDate: dueDate, docType: docType, amount: amount);
  }
}
