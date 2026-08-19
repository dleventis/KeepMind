import 'package:flutter_test/flutter_test.dart';
import 'package:keepmind/data/services/reminder_scheduler.dart';
import 'package:keepmind/domain/entities/memory_object.dart';
import 'package:keepmind/domain/entities/reminder.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../support/fake_notification_service.dart';

/// The scheduler's job is to make the database — not the OS queue — the
/// source of truth about what the user will be reminded of. These tests
/// exercise exactly that, including the case the whole design exists for:
/// the OS quietly forgetting a scheduled notification.
void main() {
  late tz.Location athens;
  late FakeNotificationService notifications;
  late FakeReminderRepository repository;
  late ReminderScheduler scheduler;

  setUpAll(() {
    tzdata.initializeTimeZones();
    athens = tz.getLocation('Europe/Athens');
  });

  setUp(() {
    notifications = FakeNotificationService();
    repository = FakeReminderRepository();
    scheduler = ReminderScheduler(
      reminders: repository,
      notifications: notifications,
    );
  });

  tz.TZDateTime at(int y, int m, int d, [int h = 0]) =>
      tz.TZDateTime(athens, y, m, d, h);

  MemoryObject memory({DateTime? eventDate, String id = 'mem-1'}) {
    final now = DateTime(2026, 8, 19);
    return MemoryObject(
      id: id,
      title: 'Car insurance',
      category: 'Document',
      sourceType: 'photo',
      createdAt: now,
      updatedAt: now,
      eventDate: eventDate,
      confirmationStatus: ConfirmationStatus.confirmed,
    );
  }

  group('scheduleFor', () {
    test('persists and registers one reminder per applicable offset',
        () async {
      final result = await scheduler.scheduleFor(
        memory(eventDate: DateTime(2026, 11, 17)),
        location: athens,
        now: at(2026, 8, 19),
      );

      expect(result.scheduled, hasLength(3));
      expect(repository.reminders, hasLength(3));
      expect(notifications.scheduled, hasLength(3));
      expect(result.permissionGranted, isTrue);
    });

    test('reports offsets skipped for being in the past', () async {
      final result = await scheduler.scheduleFor(
        memory(eventDate: DateTime(2026, 8, 26)),
        location: athens,
        now: at(2026, 8, 19, 10),
      );

      expect(result.scheduled.map((r) => r.daysBefore), [1]);
      // The UI needs this so it can tell the user only one reminder will
      // fire, rather than implying all three were set.
      expect(result.skippedInPast, [30, 7]);
    });

    test('schedules nothing when the memory has no date', () async {
      final result = await scheduler.scheduleFor(
        memory(),
        location: athens,
        now: at(2026, 8, 19),
      );

      expect(result.anyScheduled, isFalse);
      expect(notifications.scheduled, isEmpty);
      // No date means nothing to remind about — and crucially, no
      // permission prompt for a feature the user isn't using yet.
      expect(notifications.permissionRequests, 0);
    });

    test('still persists reminders when permission is denied', () async {
      notifications.permissionGranted = false;

      final result = await scheduler.scheduleFor(
        memory(eventDate: DateTime(2026, 11, 17)),
        location: athens,
        now: at(2026, 8, 19),
      );

      expect(result.permissionGranted, isFalse);
      // Rows exist so the app can re-register later if the user changes
      // their mind in Settings; nothing is registered with the OS now.
      expect(repository.reminders, hasLength(3));
      expect(notifications.scheduled, isEmpty);
    });

    test('replaces existing reminders instead of duplicating them',
        () async {
      final first = memory(eventDate: DateTime(2026, 11, 17));
      await scheduler.scheduleFor(first, location: athens, now: at(2026, 8, 19));

      // The user corrects the date; the old reminders must not survive.
      final corrected = first.copyWith(eventDate: DateTime(2026, 12, 25));
      final result = await scheduler.scheduleFor(
        corrected,
        location: athens,
        now: at(2026, 8, 19),
      );

      expect(repository.reminders, hasLength(3));
      expect(notifications.scheduled, hasLength(3));
      expect(notifications.cancelled, hasLength(3));
      for (final r in result.scheduled) {
        expect(r.triggerTime.month, anyOf(11, 12));
      }
    });
  });

  group('cancelFor', () {
    test('removes rows and cancels platform notifications', () async {
      await scheduler.scheduleFor(
        memory(eventDate: DateTime(2026, 11, 17)),
        location: athens,
        now: at(2026, 8, 19),
      );

      await scheduler.cancelFor('mem-1');

      expect(repository.reminders, isEmpty);
      expect(notifications.scheduled, isEmpty);
    });
  });

  group('reconcile', () {
    test('re-registers reminders the OS has silently dropped', () async {
      await scheduler.scheduleFor(
        memory(eventDate: DateTime(2026, 11, 17)),
        location: athens,
        now: at(2026, 8, 19),
      );

      // Reboot, force stop, or an aggressive battery manager.
      notifications.simulateOsDroppedAll();
      expect(notifications.scheduled, isEmpty);

      final report = await scheduler.reconcile(now: at(2026, 8, 20));

      expect(report.reRegistered, 3);
      expect(notifications.scheduled, hasLength(3));
    });

    test('leaves intact reminders alone', () async {
      await scheduler.scheduleFor(
        memory(eventDate: DateTime(2026, 11, 17)),
        location: athens,
        now: at(2026, 8, 19),
      );

      final report = await scheduler.reconcile(now: at(2026, 8, 20));

      expect(report.reRegistered, 0);
      expect(report.totalPending, 3);
    });

    test('retires reminders whose moment has passed as elapsed',
        () async {
      await scheduler.scheduleFor(
        memory(eventDate: DateTime(2026, 11, 17)),
        location: athens,
        now: at(2026, 8, 19),
      );

      // Launch the app after every trigger time has gone by without the
      // OS ever calling us back.
      final report = await scheduler.reconcile(now: at(2026, 12, 1));

      expect(report.markedElapsed, 3);
      final statuses =
          repository.reminders.values.map((r) => r.status).toSet();
      expect(statuses, {ReminderStatus.elapsed});
      // Nothing pointless re-registered into the past.
      expect(report.reRegistered, 0);
    });

    test('is safe to run with nothing scheduled', () async {
      final report = await scheduler.reconcile(now: at(2026, 8, 19));
      expect(report.totalPending, 0);
      expect(report.reRegistered, 0);
      expect(report.markedElapsed, 0);
    });
  });
}
