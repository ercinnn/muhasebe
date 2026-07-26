import '../../core/constants/document_enums.dart';

/// Parses the data-only FCM payload sent by the on-document-insert Edge
/// Function. Carries just enough to show an immediate "Belge Geldi"
/// notification and schedule a due-date local reminder without a network
/// round-trip — important for the background isolate handler, which has no
/// app/Riverpod state to fall back on. Sent for every new document, so
/// [dueDate] is null for info/unclassified documents (nothing to remind).
class PushPayload {
  const PushPayload({
    required this.documentId,
    required this.docType,
    required this.category,
    this.dueDate,
    this.amount,
  });

  final String documentId;
  final DateTime? dueDate;
  final DocType docType;
  final DocumentCategory category;
  final double? amount;

  static PushPayload? fromData(Map<String, dynamic> data) {
    if (data['type'] != 'new_document') return null;

    final documentId = data['document_id'] as String?;
    final docTypeRaw = data['doc_type'] as String?;
    final categoryRaw = data['category'] as String?;
    if (documentId == null || docTypeRaw == null || categoryRaw == null) return null;

    final DocType docType;
    try {
      docType = DocType.fromDb(docTypeRaw);
    } on StateError {
      return null;
    }

    final DocumentCategory category;
    try {
      category = DocumentCategory.fromDb(categoryRaw);
    } on StateError {
      return null;
    }

    final dueDateRaw = data['due_date'] as String?;
    final dueDate = dueDateRaw == null || dueDateRaw.isEmpty ? null : DateTime.tryParse(dueDateRaw);

    final amountRaw = data['amount'];
    final amount = amountRaw == null ? null : double.tryParse(amountRaw.toString());

    return PushPayload(
      documentId: documentId,
      docType: docType,
      category: category,
      dueDate: dueDate,
      amount: amount,
    );
  }
}
