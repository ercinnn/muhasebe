import 'package:intl/intl.dart';

final _dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');
final _currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);

String formatDateTr(DateTime date) => _dateFormat.format(date);

String formatCurrencyTr(double amount) => _currencyFormat.format(amount);

/// Whole days between today and [date] (negative if in the past).
int daysUntil(DateTime date) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final targetDate = DateTime(date.year, date.month, date.day);
  return targetDate.difference(todayDate).inDays;
}
