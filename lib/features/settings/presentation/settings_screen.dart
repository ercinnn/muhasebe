import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Hatırlatma bildirimleri yalnızca mobil uygulamada çalışır.\n'
            'Bu ayarlar mobil cihazınızdan yönetilir.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final hourAsync = ref.watch(reminderHourProvider);
    final daysBeforeAsync = ref.watch(reminderDaysBeforeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Bildirim Ayarları',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        hourAsync.when(
          data: (hour) => ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Hatırlatma saati'),
            subtitle: Text('${hour.toString().padLeft(2, '0')}:00'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: hour, minute: 0),
              );
              if (picked != null) {
                await ref.read(settingsRepositoryProvider).setReminderHour(picked.hour);
                ref.invalidate(reminderHourProvider);
              }
            },
          ),
          loading: () => const ListTile(title: Text('Yükleniyor...')),
          error: (error, stackTrace) => ListTile(title: Text('Hata: $error')),
        ),
        daysBeforeAsync.when(
          data: (daysBefore) => ListTile(
            leading: const Icon(Icons.event_available_outlined),
            title: const Text('Kaç gün önce hatırlatılsın'),
            subtitle: Text(daysBefore == 0 ? 'Sadece vade günü' : '$daysBefore gün önce'),
            trailing: DropdownButton<int>(
              value: daysBefore,
              items: const [
                DropdownMenuItem(value: 0, child: Text('0')),
                DropdownMenuItem(value: 1, child: Text('1')),
                DropdownMenuItem(value: 2, child: Text('2')),
                DropdownMenuItem(value: 3, child: Text('3')),
              ],
              onChanged: (value) async {
                if (value == null) return;
                await ref.read(settingsRepositoryProvider).setReminderDaysBefore(value);
                ref.invalidate(reminderDaysBeforeProvider);
              },
            ),
          ),
          loading: () => const ListTile(title: Text('Yükleniyor...')),
          error: (error, stackTrace) => ListTile(title: Text('Hata: $error')),
        ),
      ],
    );
  }
}
