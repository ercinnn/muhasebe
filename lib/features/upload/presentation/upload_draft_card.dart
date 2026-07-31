import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/document_enums.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../core/widgets/shake_wrapper.dart';
import '../../../core/widgets/status_badge.dart';
import '../../clients/data/clients_repository.dart';
import '../application/upload_controller.dart';
import '../domain/upload_draft.dart';

final _dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');

class UploadDraftCard extends StatelessWidget {
  const UploadDraftCard({super.key, required this.draft});

  final UploadDraft draft;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      child: switch (draft.status) {
          UploadDraftStatus.parsing => _StatusRow(
            icon: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            fileName: draft.fileName,
            label: 'Ayrıştırılıyor...',
          ),
          UploadDraftStatus.error => _ErrorRow(draft: draft),
          UploadDraftStatus.sent => _StatusRow(
            icon: const Icon(Icons.check_circle, color: urgencyPaid),
            fileName: draft.fileName,
            label: 'Gönderildi',
          ),
        UploadDraftStatus.needsReview || UploadDraftStatus.sending => _ReviewForm(draft: draft),
      },
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.icon, required this.fileName, required this.label});

  final Widget icon;
  final String fileName;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fileName, overflow: TextOverflow.ellipsis),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorRow extends ConsumerWidget {
  const _ErrorRow({required this.draft});

  final UploadDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShakeWrapper(
      trigger: draft.errorMessage ?? '',
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: urgencyOverdue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(draft.fileName, overflow: TextOverflow.ellipsis),
                Text(
                  draft.errorMessage ?? 'Bilinmeyen hata',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: urgencyOverdue),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Taslağı kaldır',
            onPressed: () => ref.read(uploadControllerProvider.notifier).removeDraft(draft.id),
          ),
        ],
      ),
    );
  }
}

class _ReviewForm extends ConsumerWidget {
  const _ReviewForm({required this.draft});

  final UploadDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extracted = draft.extracted;
    if (extracted == null) return const SizedBox.shrink();

    final controller = ref.read(uploadControllerProvider.notifier);
    final clientsAsync = ref.watch(myClientsProvider);
    final isSending = draft.status == UploadDraftStatus.sending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                draft.fileName,
                style: Theme.of(context).textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Taslağı kaldır',
              onPressed: isSending
                  ? null
                  : () => ref.read(uploadControllerProvider.notifier).removeDraft(draft.id),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            StatusBadge(label: extracted.category.label, color: urgencyNeutral),
            if (extracted.needsManualEntry)
              const StatusBadge(label: 'Manuel kontrol gerekli', color: urgencySoon),
            if (draft.usedOcr) const StatusBadge(label: 'OCR kullanıldı', color: urgencyNeutral),
            if (draft.isDuplicate)
              const StatusBadge(label: 'Mükerrer fiş no!', color: urgencyOverdue),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<DocType>(
          key: ValueKey('${draft.id}-docType'),
          initialValue: extracted.docType,
          decoration: const InputDecoration(labelText: 'Belge Türü'),
          items: [
            for (final type in DocType.values) DropdownMenuItem(value: type, child: Text(type.label)),
          ],
          onChanged: isSending
              ? null
              : (value) {
                  if (value == null) return;
                  controller.updateExtracted(draft.id, (e) => e.copyWith(docType: value));
                },
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey('${draft.id}-period'),
          initialValue: extracted.period ?? '',
          decoration: const InputDecoration(labelText: 'Dönem'),
          enabled: !isSending,
          onChanged: (value) =>
              controller.updateExtracted(draft.id, (e) => e.copyWith(period: value)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey('${draft.id}-amount'),
          initialValue: extracted.amount == null
              ? ''
              : extracted.amount!.toStringAsFixed(2).replaceAll('.', ','),
          decoration: const InputDecoration(labelText: 'Tutar (₺)'),
          enabled: !isSending,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => controller.updateAmountFromInput(draft.id, value),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                extracted.dueDate == null
                    ? 'Vade seçilmedi'
                    : 'Vade: ${_dateFormat.format(extracted.dueDate!)}',
              ),
            ),
            TextButton(
              onPressed: isSending
                  ? null
                  : () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: extracted.dueDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        controller.updateExtracted(draft.id, (e) => e.copyWith(dueDate: picked));
                      }
                    },
              child: const Text('Vade Seç'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey('${draft.id}-fisNo'),
          initialValue: extracted.fisNo ?? '',
          decoration: const InputDecoration(labelText: 'Fiş No'),
          enabled: !isSending,
          onChanged: (value) => controller.updateExtracted(
            draft.id,
            (e) => e.copyWith(fisNo: value.isEmpty ? null : value),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey('${draft.id}-personName'),
          initialValue: extracted.personName ?? '',
          decoration: const InputDecoration(labelText: 'Ad Soyad / Unvan'),
          enabled: !isSending,
          onChanged: (value) => controller.updateExtracted(
            draft.id,
            (e) => e.copyWith(personName: value.isEmpty ? null : value),
          ),
        ),
        const SizedBox(height: 12),
        clientsAsync.when(
          data: (clients) => DropdownButtonFormField<String>(
            key: ValueKey('${draft.id}-client'),
            initialValue: draft.selectedClientId,
            decoration: const InputDecoration(labelText: 'Mükellef Seç'),
            items: [
              for (final client in clients)
                DropdownMenuItem(value: client.id, child: Text(client.fullName)),
            ],
            onChanged: isSending
                ? null
                : (value) => controller.selectClient(draft.id, value),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => Text('Mükellef listesi yüklenemedi: $error'),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: (isSending || draft.selectedClientId == null)
                ? null
                : () => controller.send(draft.id),
            child: isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Gönder'),
          ),
        ),
      ],
    );
  }
}
