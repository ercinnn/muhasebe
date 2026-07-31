import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/document_enums.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/documents_repository.dart';
import '../widgets/payment_list_tile.dart';

/// Client-side "Ödenenler" tab — payment documents already marked paid,
/// newest payment first. The counterpart to [PaymentsScreen]'s pending
/// list; a document moves here once marked paid and back once reverted via
/// the "Ödenmedi" action on its [PaymentListTile].
class PaidDocumentsScreen extends ConsumerWidget {
  const PaidDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(clientDocumentsProvider);

    return docsAsync.when(
      data: (docs) {
        final paid =
            docs
                .where(
                  (d) =>
                      d.category == DocumentCategory.payment && d.status == DocumentStatus.paid,
                )
                .toList()
              ..sort((a, b) {
                final aDate = a.paidAt ?? DateTime(0);
                final bDate = b.paidAt ?? DateTime(0);
                return bDate.compareTo(aDate);
              });

        if (paid.isEmpty) {
          return const _EmptyPaidState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: paid.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => PaymentListTile(document: paid[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Hata: $error')),
    );
  }
}

class _EmptyPaidState extends StatelessWidget {
  const _EmptyPaidState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 40, color: GlassStyle.secondaryTextColor),
              const SizedBox(height: 12),
              Text(
                'Henüz ödenen bir belge yok.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
