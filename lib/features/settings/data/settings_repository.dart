import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_repository.g.dart';

const reminderHourPrefKey = 'reminder_hour';
const reminderDaysBeforePrefKey = 'reminder_days_before';
const defaultReminderHour = 9;
const defaultReminderDaysBefore = 1;

/// Device-local (not synced) reminder preferences — only meaningful on
/// mobile, where local alarms are actually scheduled.
class SettingsRepository {
  Future<int> getReminderHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(reminderHourPrefKey) ?? defaultReminderHour;
  }

  Future<void> setReminderHour(int hour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(reminderHourPrefKey, hour);
  }

  Future<int> getReminderDaysBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(reminderDaysBeforePrefKey) ?? defaultReminderDaysBefore;
  }

  Future<void> setReminderDaysBefore(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(reminderDaysBeforePrefKey, days);
  }
}

@riverpod
SettingsRepository settingsRepository(Ref ref) => SettingsRepository();

@riverpod
Future<int> reminderHour(Ref ref) => ref.watch(settingsRepositoryProvider).getReminderHour();

@riverpod
Future<int> reminderDaysBefore(Ref ref) =>
    ref.watch(settingsRepositoryProvider).getReminderDaysBefore();
