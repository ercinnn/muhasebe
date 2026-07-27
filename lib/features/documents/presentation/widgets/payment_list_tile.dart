import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/document_enums.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/countdown_text.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../core/widgets/pulse_wrapper.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/success_check.dart';
import '../../application/document_actions.dart';
import '../../domain/document_record.dart';
import 'document_preview_sheet.dart';
import 'due_status.dart';

class PaymentListTile extends ConsumerWidget {
  const PaymentListTile({super.key, required this.document});

  final DocumentRecord document;

  Future<void> _markPaid(WidgetRef ref) =>
      ref.read(documentActionsProvider.notifier).markPaid(document.id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = DueStatus.of(document);
    final canMarkPaid = document.status == DocumentStatus.pending;
    final isUnread = document.seenAt == null;
    final scheme = Theme.of(context).colorScheme;
    final isUrgent =
        canMarkPaid && document.dueDate != null && daysUntil(document.dueDate!) <= 1;

    final tile = GlassSurface(
      padding: EdgeInsets.zero,
      tint: isUnread ? scheme.primaryContainer.withValues(alpha: 0.25) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(GlassStyle.surfaceRadius),
        onTap: () => context.push('/document/${document.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: due.color.withValues(alpha: 0.15),
                child: Icon(Icons.receipt_long, color: due.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            document.docType.label,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.circle, size: 8, color: scheme.primary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (document.amount != null)
                      Text(
                        formatCurrencyTr(document.amount!),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    if (document.period != null) Text('Dönem: ${document.period}'),
                    if (document.dueDate != null) Text('Vade: ${formatDateTr(document.dueDate!)}'),
                    const SizedBox(height: 6),
                    PulseWrapper(
                      enabled: isUrgent,
                      child: StatusBadge(
                        label: due.label,
                        color: due.color,
                        child: (canMarkPaid && document.dueDate != null)
                            ? CountdownText(
                                dueDate: document.dueDate!,
                                fallbackLabel: due.label,
                                style: TextStyle(
                                  color: due.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (canMarkPaid)
                SuccessCheckAnimation(label: 'Ödendi', onPressed: () => _markPaid(ref))
              else if (document.status == DocumentStatus.paid)
                const Icon(Icons.check_circle, color: urgencyPaid),
            ],
          ),
        ),
      ),
    );

    return Slidable(
      key: ValueKey(document.id),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (context) => showDocumentPreviewSheet(context, document),
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            icon: Icons.visibility_outlined,
            label: 'Önizle',
            borderRadius: BorderRadius.circular(GlassStyle.surfaceRadius),
          ),
        ],
      ),
      endActionPane: canMarkPaid
          ? ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.28,
              children: [
                SlidableAction(
                  onPressed: (_) => _markPaid(ref),
                  backgroundColor: urgencyPaid,
                  foregroundColor: Colors.white,
                  icon: Icons.check_circle_outline,
                  label: 'Ödendi',
                  borderRadius: BorderRadius.circular(GlassStyle.surfaceRadius),
                ),
              ],
            )
          : null,
      child: tile,
    );
  }
}
