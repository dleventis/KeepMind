import 'package:keepmind/domain/entities/reminder.dart';
import 'package:keepmind/domain/repositories/reminder_repository.dart';
import 'package:keepmind/domain/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

/// In-memory [NotificationService] standing in for the platform plugin,
/// with hooks to simulate the failure modes that matter: a user denying
/// permission, and the OS silently dropping scheduled notifications.
class FakeNotificationService implements NotificationService {
  FakeNotificationService({this.permissionGranted = true});

  bool permissionGranted;

  final Map<int, tz.TZDateTime> scheduled = {};
  final List<int> cancelled = [];
  int permissionRequests = 0;

  /// Simulates the OS dropping everything — a reboot, a force stop, or an
  /// OEM battery manager clearing the alarm queue.
  void simulateOsDroppedAll() => scheduled.clear();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<void> schedule({
    required int notificationId,
    required tz.TZDateTime triggerTime,
    required String title,
    required String body,
    String? payload,
  }) async {
    scheduled[notificationId] = triggerTime;
  }

  @override
  Future<void> cancel(int notificationId) async {
    cancelled.add(notificationId);
    scheduled.remove(notificationId);
  }

  @override
  Future<Set<int>> pendingNotificationIds() async => scheduled.keys.toSet();
}

/// In-memory [ReminderRepository] so scheduler tests need no database.
class FakeReminderRepository implements ReminderRepository {
  final Map<String, Reminder> reminders = {};

  @override
  Future<List<Reminder>> pendingReminders() async =>
      reminders.values
          .where((r) => r.status == ReminderStatus.scheduled)
          .toList()
        ..sort((a, b) => a.triggerTime.compareTo(b.triggerTime));

  @override
  Future<List<Reminder>> remindersFor(String memoryId) async =>
      reminders.values.where((r) => r.memoryId == memoryId).toList();

  @override
  Future<void> saveAll(List<Reminder> toSave) async {
    for (final r in toSave) {
      reminders[r.id] = r;
    }
  }

  @override
  Future<void> updateStatus(String reminderId, ReminderStatus status) async {
    final existing = reminders[reminderId];
    if (existing != null) {
      reminders[reminderId] = existing.copyWith(status: status);
    }
  }

  @override
  Future<void> deleteForMemory(String memoryId) async {
    reminders.removeWhere((_, r) => r.memoryId == memoryId);
  }
}
