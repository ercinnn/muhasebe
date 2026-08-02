import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_surface.dart';
import '../data/clients_repository.dart';
import '../domain/client.dart';
import '../domain/client_contact_info.dart';

/// Accountant-only sub-tab (under Ayarlar): lets them keep phone/address/
/// notes for each of their clients — fields the app never asks the client
/// themselves for.
class ClientContactInfoScreen extends ConsumerWidget {
  const ClientContactInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(myClientsProvider);

    return clientsAsync.when(
      data: (clients) {
        if (clients.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 40,
                      color: GlassStyle.secondaryTextColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Henüz mükellefiniz yok',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: clients.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ClientContactCard(client: clients[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Hata: $error')),
    );
  }
}

class _ClientContactCard extends ConsumerStatefulWidget {
  const _ClientContactCard({required this.client});

  final Client client;

  @override
  ConsumerState<_ClientContactCard> createState() => _ClientContactCardState();
}

class _ClientContactCardState extends ConsumerState<_ClientContactCard> {
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyLoadedInfo(ClientContactInfo? info) {
    if (_loaded || info == null) return;
    _loaded = true;
    _phoneController.text = info.phone ?? '';
    _addressController.text = info.address ?? '';
    _notesController.text = info.notes ?? '';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    String? errorMessage;
    try {
      await ref
          .read(clientsRepositoryProvider)
          .saveContactInfo(
            ClientContactInfo(
              clientId: widget.client.id,
              phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
              address: _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            ),
          );
      ref.invalidate(clientContactInfoProvider(widget.client.id));
    } catch (e) {
      errorMessage = 'Kaydedilemedi: $e';
    }
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage ?? 'Kaydedildi')));
  }

  @override
  Widget build(BuildContext context) {
    final infoAsync = ref.watch(clientContactInfoProvider(widget.client.id));
    infoAsync.whenData(_applyLoadedInfo);

    return GlassSurface(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(widget.client.fullName),
        children: [
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Telefon'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Adres'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Diğer bilgiler'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}
