import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/document_enums.dart';
import '../../data/documents_repository.dart';
import '../../domain/document_record.dart';
import '../widgets/due_status.dart';
import '../widgets/payment_list_tile.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<DocumentRecord> _paymentsOn(List<DocumentRecord> docs, DateTime day) {
    return docs
        .where((d) => d.category == DocumentCategory.payment && d.dueDate != null)
        .where((d) => isSameDay(d.dueDate, day))
        .toList();
  }

  Color _markerColor(List<DocumentRecord> dayDocs) {
    final urgencies = dayDocs.map(DueStatus.of).map((s) => s.urgency);
    if (urgencies.contains(DueUrgency.overdue)) return Colors.red.shade700;
    if (urgencies.any((u) => u == DueUrgency.soon || u == DueUrgency.upcoming)) {
      return Colors.orange.shade800;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(clientDocumentsProvider);

    return docsAsync.when(
      data: (docs) {
        final selectedPayments = _paymentsOn(docs, _selectedDay);

        return Column(
          children: [
            TableCalendar<DocumentRecord>(
              locale: 'tr_TR',
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2100),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) => _paymentsOn(docs, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              onPageChanged: (focused) => _focusedDay = focused,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  return Container(
                    margin: const EdgeInsets.only(top: 28),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _markerColor(events),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: selectedPayments.isEmpty
                  ? const Center(child: Text('Bu günde ödeme yok'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: selectedPayments.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          PaymentListTile(document: selectedPayments[index]),
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
