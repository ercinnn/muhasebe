import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/document_enums.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../application/inbox_summary.dart';
import '../../data/documents_repository.dart';
import '../widgets/empty_state_celebration.dart';
import '../widgets/payment_list_tile.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(clientDocumentsProvider);
    final summary = ref.watch(inboxSummaryProvider);

    return docsAsync.when(
      data: (docs) {
        final payments = docs
            .where(
              (d) => d.category == DocumentCategory.payment && d.status != DocumentStatus.paid,
            )
            .toList()
          ..sort((a, b) {
            final aDate = a.dueDate ?? DateTime(2100);
            final bDate = b.dueDate ?? DateTime(2100);
            return aDate.compareTo(bDate);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _TotalDueHeroCard(summary: summary),
            ),
            if (summary.upcomingCount > 0) _UpcomingPaymentsBanner(summary: summary),
            Expanded(
              child: summary.pendingCount == 0
                  ? const EmptyStateCelebration()
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

class _TotalDueHeroCard extends StatelessWidget {
  const _TotalDueHeroCard({required this.summary});

  final InboxSummary summary;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toplam Bekleyen Tutar',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: GlassStyle.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedCounter(
            value: summary.pendingTotal,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${summary.pendingCount} bekleyen ödeme',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: GlassStyle.secondaryTextColor),
          ),
        ],
      ),
    );
  }
}

class _UpcomingPaymentsBanner extends StatelessWidget {
  const _UpcomingPaymentsBanner({required this.summary});

  final InboxSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GlassSurface(
        tint: scheme.primaryContainer.withValues(alpha: 0.25),
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
      ),
    );
  }
}
