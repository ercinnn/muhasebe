import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/document_enums.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../core/widgets/glass_card.dart';
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

  /// The 7x7 marker dot below a day number is color-only, so it also needs
  /// a screen-reader label — color alone conveys nothing to a screen reader
  /// (found via design-lead live review, 2026-08-01).
  ({Color color, String label}) _markerInfo(List<DocumentRecord> dayDocs) {
    final urgencies = dayDocs.map(DueStatus.of).map((s) => s.urgency).toSet();
    if (urgencies.contains(DueUrgency.overdue)) {
      return (color: urgencyOverdue, label: 'Gecikmiş ödeme var');
    }
    if (urgencies.contains(DueUrgency.soon)) {
      return (color: urgencySoon, label: 'Yaklaşan ödeme var');
    }
    if (urgencies.contains(DueUrgency.upcoming)) {
      return (color: urgencyUpcoming, label: 'Ödeme var');
    }
    return (color: urgencyPaid, label: 'Ödenmiş belge var');
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
              startingDayOfWeek: StartingDayOfWeek.monday,
              // table_calendar's default (16px) clips descenders like "Çar"'s
              // cedilla against the day grid painted right below it — found
              // via design-lead live browser review, 2026-08-01.
              daysOfWeekHeight: 24,
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                weekendDecoration: const BoxDecoration(
                  color: urgencyOverdue,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: Colors.white),
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  const labels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                  final isWeekend =
                      day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
                  return Center(
                    child: Text(
                      labels[day.weekday - 1],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isWeekend ? urgencyOverdue : null,
                      ),
                    ),
                  );
                },
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  final info = _markerInfo(events);
                  return Semantics(
                    label: info.label,
                    child: Container(
                      margin: const EdgeInsets.only(top: 28),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: info.color, shape: BoxShape.circle),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: selectedPayments.isEmpty
                  ? const Center(child: GlassCard(child: Text('Bu günde ödeme yok')))
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
