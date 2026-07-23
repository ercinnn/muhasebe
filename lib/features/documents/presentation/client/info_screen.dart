import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/document_enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/documents_repository.dart';

class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(clientDocumentsProvider);

    return docsAsync.when(
      data: (docs) {
        final infoDocs = docs.where((d) => d.category == DocumentCategory.info).toList()
          ..sort((a, b) => (b.dueDate ?? b.createdAt).compareTo(a.dueDate ?? a.createdAt));

        if (infoDocs.isEmpty) {
          return const Center(child: Text('Bilgilendirme belgesi bulunmuyor'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: infoDocs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final doc = infoDocs[index];
            return Card(
              child: ListTile(
                onTap: () => context.push('/document/${doc.id}'),
                leading: Icon(
                  doc.docType == DocType.iseGiris ? Icons.person_add_alt_1 : Icons.person_remove,
                ),
                title: Text(doc.personName ?? 'İsimsiz'),
                subtitle: Text(
                  '${doc.docType.label}'
                  '${doc.dueDate != null ? ' • ${formatDateTr(doc.dueDate!)}' : ''}',
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Hata: $error')),
    );
  }
}
