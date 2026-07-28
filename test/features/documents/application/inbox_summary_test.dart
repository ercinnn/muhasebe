import 'package:flutter_test/flutter_test.dart';
import 'package:muhasebe_takip/core/constants/document_enums.dart';
import 'package:muhasebe_takip/features/documents/application/inbox_summary.dart';
import 'package:muhasebe_takip/features/documents/domain/document_record.dart';

DocumentRecord _doc({
  DocumentCategory category = DocumentCategory.payment,
  DocumentStatus status = DocumentStatus.pending,
  double? amount,
  DateTime? dueDate,
  DateTime? seenAt,
}) => DocumentRecord(
  id: 'doc-${identityHashCode(dueDate)}-${amount ?? 0}',
  createdAt: DateTime(2026, 1, 1),
  accountantId: 'accountant-1',
  clientId: 'client-1',
  category: category,
  docType: DocType.kdv,
  amount: amount,
  dueDate: dueDate,
  storagePath: 'path.pdf',
  status: status,
  seenAt: seenAt,
);

void main() {
  final now = DateTime.now();
  DateTime inDays(int days) => DateTime(now.year, now.month, now.day).add(Duration(days: days));

  group('computeInboxSummary', () {
    test('empty list yields all-zero summary', () {
      final summary = computeInboxSummary(const []);

      expect(summary.unreadCount, 0);
      expect(summary.upcomingCount, 0);
      expect(summary.upcomingTotal, 0);
      expect(summary.pendingCount, 0);
      expect(summary.pendingTotal, 0);
    });

    test('counts docs with seenAt == null as unread, regardless of category/status', () {
      final docs = [
        _doc(seenAt: null),
        _doc(seenAt: DateTime(2026, 1, 2)),
        _doc(category: DocumentCategory.info, status: DocumentStatus.info, seenAt: null),
      ];

      expect(computeInboxSummary(docs).unreadCount, 2);
    });

    test('only pending payment docs count toward pendingCount/pendingTotal', () {
      final docs = [
        _doc(amount: 100), // payment + pending -> counts
        _doc(amount: 50, status: DocumentStatus.paid), // already paid -> excluded
        _doc(amount: 200, category: DocumentCategory.info, status: DocumentStatus.info), // info -> excluded
      ];

      final summary = computeInboxSummary(docs);
      expect(summary.pendingCount, 1);
      expect(summary.pendingTotal, 100);
    });

    test('only pending payments due within 7 days count toward upcoming', () {
      final docs = [
        _doc(amount: 100, dueDate: inDays(3)), // within window
        _doc(amount: 200, dueDate: inDays(7)), // boundary, inclusive
        _doc(amount: 300, dueDate: inDays(8)), // outside window
        _doc(amount: 400, dueDate: null), // no due date -> excluded from upcoming
      ];

      final summary = computeInboxSummary(docs);
      expect(summary.upcomingCount, 2);
      expect(summary.upcomingTotal, 300);
      // pendingTotal still includes every pending payment, window or not.
      expect(summary.pendingTotal, 1000);
    });

    test('null amounts are treated as 0 rather than throwing', () {
      final docs = [_doc(amount: null, dueDate: inDays(1))];

      final summary = computeInboxSummary(docs);
      expect(summary.pendingTotal, 0);
      expect(summary.upcomingTotal, 0);
    });
  });
}
