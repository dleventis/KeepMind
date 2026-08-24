import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/id_generator.dart';
import '../../domain/entities/memory_object.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/services/notification_service.dart';
import '../../domain/services/reminder_planner.dart';

/// Outcome of scheduling, so the UI can tell the user exactly what will
/// happen rather than claiming success and hoping.
class SchedulingResult {
  const SchedulingResult({
    required this.scheduled,
    required this.skippedInPast,
    required this.permissionGranted,
  });

  final List<Reminder> scheduled;

  /// Offsets that fell in the past and were not scheduled — e.g. asking
  /// for "7 days before" on something happening in 3 days.
  final List<int> skippedInPast;

  final bool permissionGranted;

  bool get anyScheduled => scheduled.isNotEmpty;
}

/// Owns the lifecycle of reminders: plan, persist, register with the OS,
/// and — critically — reconcile at launch.
///
/// The design rule from docs/REMINDERS.md is that the database is the
/// source of truth and the OS notification queue is a cache of it. The OS
/// drops scheduled notifications for reasons outside our control (force
/// stop, app update, some OEM battery managers, permission revoked), so
/// "we called schedule() once" is never treated as "the user will be
/// reminded".
class ReminderScheduler {
  ReminderScheduler({
    required this.reminders,
    required this.notifications,
  });

  // Public final rather than private. A named parameter cannot begin
  // with an underscore, so an initializing formal is impossible for a
  // private field passed by name — it would need a redundant initializer
  // list instead. These are immutable injected collaborators; there is
  // nothing to encapsulate.
  final ReminderRepository reminders;
  final NotificationService notifications;

  /// Plans and schedules reminders for a confirmed memory, replacing any
  /// it already had (so editing a date doesn't leave the old reminders
  /// behind).
  Future<SchedulingResult> scheduleFor(
    MemoryObject memory, {
    Set<int> daysBefore = ReminderPlanner.defaultDaysBefore,
    tz.Location? location,
    tz.TZDateTime? now,
  }) async {
    await cancelFor(memory.id);

    final eventDate = memory.eventDate;
    if (eventDate == null || daysBefore.isEmpty) {
      return const SchedulingResult(
        scheduled: [],
        skippedInPast: [],
        permissionGranted: true,
      );
    }

    final loc = location ?? tz.local;
    final currentTime = now ?? tz.TZDateTime.now(loc);

    final planned = ReminderPlanner.plan(
      eventDate: eventDate,
      daysBefore: daysBefore,
      location: loc,
      now: currentTime,
    );

    final plannedOffsets = planned.map((p) => p.daysBefore).toSet();
    // `d >= 0` because the planner also drops negative offsets, and those
    // are invalid input rather than "would have been in the past" —
    // reporting them as the latter would put a confusing message in front
    // of the user.
    final skipped = daysBefore
        .where((d) => d >= 0 && !plannedOffsets.contains(d))
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (planned.isEmpty) {
      return SchedulingResult(
        scheduled: const [],
        skippedInPast: skipped,
        permissionGranted: true,
      );
    }

    // Only ask for permission once we actually have something to
    // schedule — a prompt with nothing behind it gets denied, and on iOS
    // there is no second chance.
    final granted = await notifications.requestPermissions();

    final created = <Reminder>[];
    for (final p in planned) {
      final id = IdGenerator.generate();
      created.add(Reminder(
        id: id,
        memoryId: memory.id,
        triggerTime: p.triggerTime,
        timezone: p.timezoneName,
        status: ReminderStatus.scheduled,
        createdAt: DateTime.now(),
        daysBefore: p.daysBefore,
        notificationId: ReminderPlanner.notificationIdFor(id),
      ));
    }

    // Persist BEFORE registering with the OS. If the process dies
    // between the two, reconciliation at next launch re-registers from
    // the database — whereas an OS-registered notification with no row
    // behind it would be invisible to us forever.
    await reminders.saveAll(created);

    if (granted) {
      for (var i = 0; i < created.length; i++) {
        await _register(created[i], memory, planned[i].triggerTime);
      }
    }

    return SchedulingResult(
      scheduled: created,
      skippedInPast: skipped,
      permissionGranted: granted,
    );
  }

  Future<void> cancelFor(String memoryId) async {
    final existing = await reminders.remindersFor(memoryId);
    for (final r in existing) {
      await notifications.cancel(r.notificationId);
    }
    await reminders.deleteForMemory(memoryId);
  }

  /// Re-registers everything the database says should be pending, and
  /// retires anything whose moment has already passed.
  ///
  /// Pass [memoriesById] so re-registered notifications keep their real
  /// titles; without it they fall back to a generic string.
  ///
  /// Call on every app launch, and after the OS reports a reboot. Cheap
  /// (a handful of rows) and it is the only thing standing between a
  /// dropped OS notification and a user who never gets told their
  /// passport expired.
  Future<ReconciliationReport> reconcile({
    Map<String, MemoryObject> memoriesById = const {},
    tz.TZDateTime? now,
  }) async {
    final currentTime = now ?? tz.TZDateTime.now(tz.local);
    final pending = await reminders.pendingReminders();
    final osPending = await notifications.pendingNotificationIds();

    var reRegistered = 0;
    var markedElapsed = 0;
    var registeredCount = osPending.length;

    for (final reminder in pending) {
      if (!reminder.triggerTime.isAfter(currentTime)) {
        // Its moment has passed, so we no longer expect it to fire. We
        // genuinely cannot tell whether the user saw it: the platform
        // reports taps, never deliveries. `elapsed` says exactly that and
        // nothing more — claiming "missed" here would libel every
        // reminder that was shown and swiped away.
        await reminders.updateStatus(reminder.id, ReminderStatus.elapsed);
        markedElapsed++;
        continue;
      }

      if (osPending.contains(reminder.notificationId)) continue;

      // iOS silently drops anything beyond 64 pending local notifications
      // — and silently dropping the *soonest* ones would be the worst
      // possible failure. `pending` is ordered by trigger time, so
      // stopping here keeps the nearest reminders registered and leaves
      // the far-future ones to a later launch, by which time they will
      // have moved up the queue.
      if (registeredCount >= _maxPlatformNotifications) break;

      // Still in the future, but the OS has no record of it — exactly the
      // case this whole mechanism exists for.
      final memory = memoriesById[reminder.memoryId];
      await _register(
        reminder,
        memory,
        tz.TZDateTime.from(reminder.triggerTime, tz.local),
      );
      reRegistered++;
      registeredCount++;
    }

    return ReconciliationReport(
      reRegistered: reRegistered,
      markedElapsed: markedElapsed,
      totalPending: pending.length,
    );
  }

  /// iOS caps pending local notifications at 64 per app; Android has no
  /// hard cap but no reason to exceed it either.
  static const int _maxPlatformNotifications = 64;

  Future<void> _register(
    Reminder reminder,
    MemoryObject? memory,
    tz.TZDateTime triggerTime,
  ) async {
    await notifications.schedule(
      notificationId: reminder.notificationId,
      triggerTime: triggerTime,
      title: memory?.title ?? 'KeepMind reminder',
      body: _bodyFor(reminder, memory),
      payload: reminder.memoryId,
    );
  }

  String _bodyFor(Reminder reminder, MemoryObject? memory) {
    final days = reminder.daysBefore;
    final when = switch (days) {
      0 => 'today',
      1 => 'tomorrow',
      _ => 'in $days days',
    };
    final what = memory?.title ?? 'Something you saved';
    return '$what — $when.';
  }
}

class ReconciliationReport {
  const ReconciliationReport({
    required this.reRegistered,
    required this.markedElapsed,
    required this.totalPending,
  });

  /// Reminders the OS had forgotten and we put back.
  final int reRegistered;

  /// Reminders whose moment passed while the app wasn't running.
  final int markedElapsed;

  final int totalPending;
}
