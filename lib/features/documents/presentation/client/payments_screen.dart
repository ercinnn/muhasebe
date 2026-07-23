import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/document_enums.dart';
import '../../data/documents_repository.dart';
import '../widgets/payment_list_tile.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(clientDocumentsProvider);

    return docsAsync.when(
      data: (docs) {
        final payments = docs.where((d) => d.category == DocumentCategory.payment).toList()
          ..sort((a, b) {
            final aDate = a.dueDate ?? DateTime(2100);
            final bDate = b.dueDate ?? DateTime(2100);
            return aDate.compareTo(bDate);
          });

        if (payments.isEmpty) {
          return const Center(child: Text('Ödeme bulunmuyor'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => PaymentListTile(document: payments[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Hata: $error')),
    );
  }
}
