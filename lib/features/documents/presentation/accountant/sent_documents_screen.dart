import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/document_enums.dart';
import '../../../../core/utils/formatters.dart';
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
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: _clientFilter,
                      decoration: const InputDecoration(labelText: 'Mükellef'),
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
                      decoration: const InputDecoration(labelText: 'Durum'),
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
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('Gönderilen belge bulunmuyor'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        final due = DueStatus.of(doc);
                        return Card(
                          child: ListTile(
                            onTap: () => context.push('/document/${doc.id}'),
                            leading: CircleAvatar(
                              backgroundColor: due.color.withValues(alpha: 0.15),
                              child: Icon(Icons.description_outlined, color: due.color),
                            ),
                            title: Text(clientNames[doc.clientId] ?? doc.clientId),
                            subtitle: Text(
                              '${doc.docType.label}'
                              '${doc.period != null ? ' • ${doc.period}' : ''}'
                              '${doc.dueDate != null ? ' • Vade: ${formatDateTr(doc.dueDate!)}' : ''}',
                            ),
                            trailing: _StatusChip(document: doc),
                          ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.document});

  final DocumentRecord document;

  @override
  Widget build(BuildContext context) {
    final due = DueStatus.of(document);
    return Chip(
      label: Text(document.status == DocumentStatus.pending ? due.label : document.status.label),
      backgroundColor: due.color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: due.color, fontWeight: FontWeight.w600),
    );
  }
}
