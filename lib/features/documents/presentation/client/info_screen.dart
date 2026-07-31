import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/document_enums.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glass_surface.dart';
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
          return const Center(child: GlassCard(child: Text('Bilgilendirme belgesi bulunmuyor')));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: infoDocs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final doc = infoDocs[index];
            final isUnread = doc.seenAt == null;
            final scheme = Theme.of(context).colorScheme;
            return GlassSurface(
              padding: EdgeInsets.zero,
              tint: isUnread ? scheme.primaryContainer.withValues(alpha: 0.25) : null,
              child: InkWell(
                borderRadius: BorderRadius.circular(GlassStyle.surfaceRadius),
                onTap: () => context.push('/document/${doc.id}'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: urgencyNeutral.withValues(alpha: 0.15),
                        child: Icon(
                          doc.docType == DocType.iseGiris
                              ? Icons.person_add_alt_1
                              : Icons.person_remove,
                          color: urgencyNeutral,
                        ),
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
                                    doc.personName ?? 'İsimsiz',
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
                            Text(
                              '${doc.docType.label}'
                              '${doc.dueDate != null ? ' • ${formatDateTr(doc.dueDate!)}' : ''}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
