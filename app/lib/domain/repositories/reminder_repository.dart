import '../entities/reminder.dart';

/// Persistence for reminders. The database is the source of truth for
/// what *should* be scheduled; the OS's notification queue is only ever
/// a cache of that (docs/REMINDERS.md).
abstract interface class ReminderRepository {
  /// Every reminder still expected to fire, oldest trigger first.
  Future<List<Reminder>> pendingReminders();

  Future<List<Reminder>> remindersFor(String memoryId);

  Future<void> saveAll(List<Reminder> reminders);

  Future<void> updateStatus(String reminderId, ReminderStatus status);

  /// Removes all reminders for a memory — used when its date changes or
  /// the memory is deleted.
  Future<void> deleteForMemory(String memoryId);
}
