import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../data/documents_repository.dart';
import '../../domain/document_record.dart';

/// Quick-look PDF preview, opened via a swipe action on [PaymentListTile] —
/// additive to (does not replace) the full-screen `/document/:id` route.
Future<void> showDocumentPreviewSheet(BuildContext context, DocumentRecord document) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _DocumentPreviewSheet(document: document),
  );
}

class _DocumentPreviewSheet extends ConsumerWidget {
  const _DocumentPreviewSheet({required this.document});

  final DocumentRecord document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          document.docType.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Kapat',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: FutureBuilder<String>(
                    future: ref
                        .read(documentsRepositoryProvider)
                        .createSignedUrl(document.storagePath),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Center(child: Text('PDF yüklenemedi: ${snapshot.error}'));
                      }
                      return PdfViewer.uri(Uri.parse(snapshot.data!));
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
