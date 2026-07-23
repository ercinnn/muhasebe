import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/upload_controller.dart';
import 'upload_draft_card.dart';

class UploadScreen extends ConsumerWidget {
  const UploadScreen({super.key});

  Future<void> _pickFiles(WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    final files = [
      for (final f in result.files)
        if (f.bytes != null) (name: f.name, bytes: f.bytes!),
    ];
    if (files.isNotEmpty) {
      await ref.read(uploadControllerProvider.notifier).addFiles(files);
    }
  }

  Future<void> _handleDrop(WidgetRef ref, DropDoneDetails details) async {
    final files = <PickedPdfFile>[];
    for (final item in details.files) {
      if (!item.name.toLowerCase().endsWith('.pdf')) continue;
      files.add((name: item.name, bytes: await item.readAsBytes()));
    }
    if (files.isNotEmpty) {
      await ref.read(uploadControllerProvider.notifier).addFiles(files);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(uploadControllerProvider);

    return DropTarget(
      onDragDone: (details) => _handleDrop(ref, details),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: () => _pickFiles(ref),
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('PDF Seç (çoklu seçim, sürükle-bırak desteklenir)'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: drafts.isEmpty
                  ? const Center(child: Text('Henüz belge eklenmedi'))
                  : ListView.separated(
                      itemCount: drafts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final draft = drafts[index];
                        return UploadDraftCard(key: ValueKey(draft.id), draft: draft);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
