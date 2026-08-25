import 'package:drift/drift.dart';

import '../../core/errors/app_errors.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../local/database/app_database.dart';

class DriftReminderRepository implements ReminderRepository {
  DriftReminderRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Reminder>> pendingReminders() async {
    final rows =
        await (_db.select(_db.reminders)
              ..where((t) => t.status.equals(ReminderStatus.scheduled.index))
              ..orderBy([(t) => OrderingTerm(expression: t.triggerTime)]))
            .get();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<List<Reminder>> remindersFor(String memoryId) async {
    final rows =
        await (_db.select(_db.reminders)
              ..where((t) => t.memoryId.equals(memoryId))
              ..orderBy([(t) => OrderingTerm(expression: t.triggerTime)]))
            .get();
    return rows.map(_toEntity).toList(growable: false);
  }

  @override
  Future<void> saveAll(List<Reminder> reminders) async {
    if (reminders.isEmpty) return;
    try {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.reminders,
          reminders.map(_toCompanion).toList(growable: false),
        );
      });
    } catch (e) {
      throw StorageError(debugMessage: 'Failed to save reminders: $e');
    }
  }

  @override
  Future<void> updateStatus(String reminderId, ReminderStatus status) async {
    final now = DateTime.now();
    try {
      await (_db.update(
        _db.reminders,
      )..where((t) => t.id.equals(reminderId))).write(
        RemindersCompanion(
          status: Value(status.index),
          // Written by the same transition that sets the status, so
          // "acknowledged" can never be true with no timestamp behind it.
          acknowledgedAt: status == ReminderStatus.acknowledged
              ? Value(now)
              : const Value.absent(),
        ),
      );
    } catch (e) {
      throw StorageError(
        debugMessage: 'Failed to update reminder $reminderId: $e',
      );
    }
  }

  @override
  Future<void> deleteForMemory(String memoryId) async {
    try {
      await (_db.delete(
        _db.reminders,
      )..where((t) => t.memoryId.equals(memoryId))).go();
    } catch (e) {
      throw StorageError(
        debugMessage: 'Failed to delete reminders for $memoryId: $e',
      );
    }
  }

  Reminder _toEntity(ReminderRow row) => Reminder(
    id: row.id,
    memoryId: row.memoryId,
    triggerTime: row.triggerTime,
    timezone: row.timezone,
    status: ReminderStatus.values[row.status],
    createdAt: row.createdAt,
    daysBefore: row.daysBefore,
    notificationId: row.notificationId,
    acknowledgedAt: row.acknowledgedAt,
  );

  RemindersCompanion _toCompanion(Reminder r) => RemindersCompanion.insert(
    id: r.id,
    memoryId: r.memoryId,
    triggerTime: r.triggerTime,
    timezone: r.timezone,
    status: r.status.index,
    createdAt: r.createdAt,
    daysBefore: r.daysBefore,
    notificationId: r.notificationId,
    acknowledgedAt: Value(r.acknowledgedAt),
  );
}
