import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/document_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../application/document_actions.dart';
import '../../domain/document_record.dart';
import 'due_status.dart';

class PaymentListTile extends ConsumerWidget {
  const PaymentListTile({super.key, required this.document});

  final DocumentRecord document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = DueStatus.of(document);
    final canMarkPaid = document.status == DocumentStatus.pending;
    final isUnread = document.seenAt == null;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: isUnread ? scheme.primaryContainer.withValues(alpha: 0.35) : null,
      child: ListTile(
        onTap: () => context.push('/document/${document.id}'),
        isThreeLine: true,
        leading: CircleAvatar(
          backgroundColor: due.color.withValues(alpha: 0.15),
          child: Icon(Icons.receipt_long, color: due.color),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              document.docType.label,
              style: TextStyle(fontWeight: isUnread ? FontWeight.bold : null),
            ),
            if (isUnread) ...[
              const SizedBox(width: 6),
              Icon(Icons.circle, size: 8, color: scheme.primary),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (document.amount != null)
              Text(
                formatCurrencyTr(document.amount!),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            if (document.period != null) Text('Dönem: ${document.period}'),
            if (document.dueDate != null) Text('Vade: ${formatDateTr(document.dueDate!)}'),
            Text(due.label, style: TextStyle(color: due.color, fontWeight: FontWeight.w600)),
          ],
        ),
        trailing: canMarkPaid
            ? FilledButton.tonal(
                onPressed: () async {
                  await ref.read(documentActionsProvider.notifier).markPaid(document.id);
                },
                child: const Text('Ödendi'),
              )
            : (document.status == DocumentStatus.paid
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null),
      ),
    );
  }
}
