import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/breakpoints.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_surface.dart';
import '../data/clients_repository.dart';
import '../domain/client.dart';
import '../domain/invite.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  Future<void> _showCreateInviteDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final clientName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Davet Kodu Oluştur'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Mükellef Adı / Unvanı'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
    if (clientName == null || clientName.isEmpty) return;

    try {
      final invite = await ref
          .read(clientsRepositoryProvider)
          .createInvite(clientName: clientName);
      ref.invalidate(myInvitesProvider);
      if (context.mounted) await _showInviteCodeDialog(context, invite);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Davet oluşturulamadı: $e')));
      }
    }
  }

  Future<void> _showInviteCodeDialog(BuildContext context, Invite invite) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${invite.clientName} için davet kodu'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(invite.code, style: Theme.of(context).textTheme.headlineSmall),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Kopyala',
              onPressed: () => Clipboard.setData(ClipboardData(text: invite.code)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(myClientsProvider);
    final invitesAsync = ref.watch(myInvitesProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: () => _showCreateInviteDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Davet Kodu Oluştur'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: clientsAsync.when(
              data: (clients) {
                final pendingInvites = invitesAsync.value ?? [];
                if (clients.isEmpty && pendingInvites.isEmpty) {
                  return const Center(
                    child: GlassCard(child: Text('Henüz mükellef eklenmedi')),
                  );
                }
                final isWide = MediaQuery.sizeOf(context).width >= Breakpoints.rail;
                return isWide
                    ? _ClientsTable(clients: clients, pendingInvites: pendingInvites)
                    : _ClientsList(clients: clients, pendingInvites: pendingInvites);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Hata: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientsList extends StatelessWidget {
  const _ClientsList({required this.clients, required this.pendingInvites});

  final List<Client> clients;
  final List<Invite> pendingInvites;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      children: [
        for (final client in clients)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassSurface(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primary.withValues(alpha: 0.15),
                    child: Icon(Icons.business, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const Text('Aktif mükellef', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (pendingInvites.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Bekleyen Davetler', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (final invite in pendingInvites)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassSurface(
                tint: scheme.primaryContainer.withValues(alpha: 0.25),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: urgencySoon.withValues(alpha: 0.15),
                      child: const Icon(Icons.hourglass_empty, color: urgencySoon),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invite.clientName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text('Kod: ${invite.code}', style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Kodu kopyala',
                      onPressed: () => Clipboard.setData(ClipboardData(text: invite.code)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Web table view for wide viewports, per spec.
class _ClientsTable extends StatelessWidget {
  const _ClientsTable({required this.clients, required this.pendingInvites});

  final List<Client> clients;
  final List<Invite> pendingInvites;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassCard(
        borderRadius: BorderRadius.circular(GlassStyle.surfaceRadius),
        padding: const EdgeInsets.all(8),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Ad Soyad / Unvan')),
            DataColumn(label: Text('Durum')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final client in clients)
              DataRow(
                cells: [
                  DataCell(Text(client.fullName)),
                  const DataCell(Text('Aktif mükellef')),
                  const DataCell(SizedBox.shrink()),
                ],
              ),
            for (final invite in pendingInvites)
              DataRow(
                cells: [
                  DataCell(Text(invite.clientName)),
                  DataCell(Text('Bekliyor — Kod: ${invite.code}')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Kodu kopyala',
                      onPressed: () => Clipboard.setData(ClipboardData(text: invite.code)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
