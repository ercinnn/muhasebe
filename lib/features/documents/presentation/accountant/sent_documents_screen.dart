import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/document_enums.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../clients/data/clients_repository.dart';
import '../../data/documents_repository.dart';
import '../../domain/document_record.dart';
import '../widgets/due_status.dart';

class SentDocumentsScreen extends ConsumerStatefulWidget {
  const SentDocumentsScreen({super.key});

  @override
  ConsumerState<SentDocumentsScreen> createState() => _SentDocumentsScreenState();
}

class _SentDocumentsScreenState extends ConsumerState<SentDocumentsScreen> {
  String? _clientFilter;
  DocumentStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(accountantDocumentsProvider);
    final clientsAsync = ref.watch(myClientsProvider);

    return docsAsync.when(
      data: (docs) {
        final clients = clientsAsync.value ?? [];
        final clientNames = {for (final c in clients) c.id: c.fullName};

        var filtered = docs;
        if (_clientFilter != null) {
          filtered = filtered.where((d) => d.clientId == _clientFilter).toList();
        }
        if (_statusFilter != null) {
          filtered = filtered.where((d) => d.status == _statusFilter).toList();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: GlassSurface(
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: _clientFilter,
                        decoration: const InputDecoration(labelText: 'Mükellef', border: InputBorder.none),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Tümü')),
                          for (final c in clients)
                            DropdownMenuItem(value: c.id, child: Text(c.fullName)),
                        ],
                        onChanged: (value) => setState(() => _clientFilter = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<DocumentStatus?>(
                        initialValue: _statusFilter,
                        decoration: const InputDecoration(labelText: 'Durum', border: InputBorder.none),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Tümü')),
                          for (final s in DocumentStatus.values)
                            DropdownMenuItem(value: s, child: Text(s.label)),
                        ],
                        onChanged: (value) => setState(() => _statusFilter = value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: GlassCard(child: Text('Gönderilen belge bulunmuyor')),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        return _SentDocumentTile(
                          document: doc,
                          clientName: clientNames[doc.clientId] ?? doc.clientId,
                        );
                      },
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

class _SentDocumentTile extends StatelessWidget {
  const _SentDocumentTile({required this.document, required this.clientName});

  final DocumentRecord document;
  final String clientName;

  @override
  Widget build(BuildContext context) {
    final due = DueStatus.of(document);
    return GlassSurface(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(GlassStyle.surfaceRadius),
        onTap: () => context.push('/document/${document.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: due.color.withValues(alpha: 0.15),
                child: Icon(Icons.description_outlined, color: due.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clientName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '${document.docType.label}'
                      '${document.period != null ? ' • ${document.period}' : ''}'
                      '${document.dueDate != null ? ' • Vade: ${formatDateTr(document.dueDate!)}' : ''}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: document.status == DocumentStatus.pending ? due.label : document.status.label,
                color: due.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
