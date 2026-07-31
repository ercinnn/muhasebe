import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/constants/document_enums.dart';
import '../../../core/theme/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../auth/application/auth_controller.dart';
import '../application/document_actions.dart';
import '../data/documents_repository.dart';
import '../domain/document_record.dart';

class DocumentDetailScreen extends ConsumerStatefulWidget {
  const DocumentDetailScreen({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  bool _markedSeen = false;

  @override
  Widget build(BuildContext context) {
    final docAsync = ref.watch(documentByIdProvider(widget.documentId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Belge Detayı'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientScaffoldBackground(
        child: docAsync.when(
          data: (doc) {
            if (doc == null) return const Center(child: Text('Belge bulunamadı'));

            final user = ref.read(authControllerProvider).value;
            if (!_markedSeen && user?.role == UserRole.client) {
              _markedSeen = true;
              // Postgrest builders are lazy (only fire on `.then()`/await), so
              // this fire-and-forget call needs an explicit eager Future
              // wrapper — build() itself can't be async.
              Future(() async {
                await ref.read(documentsRepositoryProvider).markSeen(doc.id);
              });
            }

            return _DetailBody(document: doc);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Hata: $error')),
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.document});

  final DocumentRecord document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= Breakpoints.rail;
    final fields = _FieldsPanel(document: document);
    final viewer = _PdfPanel(storagePath: document.storagePath);

    if (isWide) {
      return Row(
        children: [
          SizedBox(width: 360, child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: fields)),
          const VerticalDivider(width: 1),
          Expanded(child: viewer),
        ],
      );
    }

    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(16), child: fields),
        const Divider(height: 1),
        Expanded(child: viewer),
      ],
    );
  }
}

class _FieldsPanel extends ConsumerWidget {
  const _FieldsPanel({required this.document});

  final DocumentRecord document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(document.docType.label, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(document.category.label),
          const SizedBox(height: 16),
          if (document.personName != null) _Field('Ad Soyad / Unvan', document.personName!),
          if (document.period != null) _Field('Dönem', document.period!),
          if (document.amount != null) _Field('Tutar', formatCurrencyTr(document.amount!)),
          if (document.dueDate != null) _Field('Vade / Tarih', formatDateTr(document.dueDate!)),
          if (document.fisNo != null) _Field('Fiş No', document.fisNo!),
          _Field('Durum', document.status.label),
          if (document.paidAt != null) _Field('Ödeme Tarihi', formatDateTr(document.paidAt!)),
          if (document.status == DocumentStatus.pending) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await ref.read(documentActionsProvider.notifier).markPaid(document.id);
              },
              child: const Text('Ödendi olarak işaretle'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _PdfPanel extends ConsumerWidget {
  const _PdfPanel({required this.storagePath});

  final String storagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: ref.read(documentsRepositoryProvider).createSignedUrl(storagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('PDF yüklenemedi: ${snapshot.error}'));
        }
        return PdfViewer.uri(Uri.parse(snapshot.data!));
      },
    );
  }
}
