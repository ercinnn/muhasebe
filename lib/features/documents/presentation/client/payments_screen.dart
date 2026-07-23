import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/document_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../application/inbox_summary.dart';
import '../../data/documents_repository.dart';
import '../widgets/payment_list_tile.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(clientDocumentsProvider);
    final summary = ref.watch(inboxSummaryProvider);

    return docsAsync.when(
      data: (docs) {
        final payments = docs.where((d) => d.category == DocumentCategory.payment).toList()
          ..sort((a, b) {
            final aDate = a.dueDate ?? DateTime(2100);
            final bDate = b.dueDate ?? DateTime(2100);
            return aDate.compareTo(bDate);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (summary.upcomingCount > 0) _UpcomingPaymentsBanner(summary: summary),
            Expanded(
              child: payments.isEmpty
                  ? const Center(child: Text('Ödeme bulunmuyor'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: payments.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => PaymentListTile(document: payments[index]),
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Hata: $error')),
    );
  }
}

class _UpcomingPaymentsBanner extends StatelessWidget {
  const _UpcomingPaymentsBanner({required this.summary});

  final InboxSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: scheme.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Yaklaşan ödemeler (7 gün): ${summary.upcomingCount} adet, '
              '${formatCurrencyTr(summary.upcomingTotal)}',
              style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
