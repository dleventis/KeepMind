import 'package:flutter_test/flutter_test.dart';
import 'package:keepmind/domain/services/reminder_planner.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Reminder reliability is the product promise, so this suite leans hard
/// on the cases that quietly break date maths in real apps: DST
/// boundaries, month ends, leap years, and offsets that land in the past.
/// All pure — no device, no plugin, no clock of its own.
void main() {
  late tz.Location athens;

  setUpAll(() {
    tzdata.initializeTimeZones();
    athens = tz.getLocation('Europe/Athens');
  });

  tz.TZDateTime at(int y, int m, int d, [int h = 0, int min = 0]) =>
      tz.TZDateTime(athens, y, m, d, h, min);

  group('basic planning', () {
    test('plans one reminder per offset for a distant event', () {
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2026, 11, 17),
        daysBefore: {30, 7, 1},
        location: athens,
        now: at(2026, 8, 19),
      );

      expect(planned, hasLength(3));
      expect(planned.map((p) => p.daysBefore), [30, 7, 1]);
    });

    test('returns soonest first', () {
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2026, 11, 17),
        daysBefore: {1, 30, 7},
        location: athens,
        now: at(2026, 8, 19),
      );
      for (var i = 1; i < planned.length; i++) {
        expect(
          planned[i].triggerTime.isAfter(planned[i - 1].triggerTime),
          isTrue,
        );
      }
    });

    test('30 days before 17 Nov is 18 Oct at 09:00 local', () {
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2026, 11, 17),
        daysBefore: {30},
        location: athens,
        now: at(2026, 8, 19),
      );
      final trigger = planned.single.triggerTime;
      expect(trigger.year, 2026);
      expect(trigger.month, 10);
      expect(trigger.day, 18);
      expect(trigger.hour, 9);
    });

    test('records the timezone it resolved against', () {
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2026, 11, 17),
        daysBefore: {1},
        location: athens,
        now: at(2026, 8, 19),
      );
      expect(planned.single.timezoneName, 'Europe/Athens');
    });
  });

  group('offsets that fall in the past are skipped', () {
    test('drops offsets earlier than now', () {
      // Event is 7 days out and it is already 10:00, so the "7 days
      // before" reminder would have been at 09:00 today — gone.
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2026, 8, 26),
        daysBefore: {30, 7, 1},
        location: athens,
        now: at(2026, 8, 19, 10),
      );
      expect(planned.map((p) => p.daysBefore), [1]);
    });

    test('keeps a same-day offset that has not yet passed', () {
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2026, 8, 26),
        daysBefore: {7},
        location: athens,
        now: at(2026, 8, 19, 7),
      );
      expect(planned, hasLength(1));
      expect(planned.single.triggerTime.hour, 9);
    });

    test('an event happening today schedules nothing', () {
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2026, 8, 19),
        daysBefore: {30, 7, 1},
        location: athens,
        now: at(2026, 8, 19, 10),
      );
      expect(planned, isEmpty);
    });
  });

  group('calendar arithmetic', () {
    test('walks back across a month boundary', () {
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2026, 3, 1),
        daysBefore: {30},
        location: athens,
        now: at(2026, 1, 1),
      );
      final t = planned.single.triggerTime;
      expect([t.month, t.day], [1, 30]);
    });

    test('accounts for a leap day', () {
      // 2028 is a leap year, so 30 days before 1 March is 31 January,
      // not 30 January.
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2028, 3, 1),
        daysBefore: {30},
        location: athens,
        now: at(2028, 1, 1),
      );
      final t = planned.single.triggerTime;
      expect([t.month, t.day], [1, 31]);
    });

    test('walks back across a year boundary', () {
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2027, 1, 5),
        daysBefore: {30},
        location: athens,
        now: at(2026, 11, 1),
      );
      final t = planned.single.triggerTime;
      expect([t.year, t.month, t.day], [2026, 12, 6]);
    });
  });

  group('daylight saving', () {
    test('stays at 09:00 civil time across the spring-forward boundary', () {
      // Europe/Athens springs forward on 29 March 2026. A reminder landing
      // on that day must still be 09:00 local, not 08:00 or 10:00.
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2026, 4, 28),
        daysBefore: {30},
        location: athens,
        now: at(2026, 3, 1),
      );
      final t = planned.single.triggerTime;
      expect([t.month, t.day], [3, 29]);
      expect(t.hour, 9);
      expect(t.timeZoneOffset, const Duration(hours: 3));
    });

    test('stays at 09:00 civil time across the fall-back boundary', () {
      // Athens falls back on 25 October 2026.
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2026, 11, 24),
        daysBefore: {30},
        location: athens,
        now: at(2026, 9, 1),
      );
      final t = planned.single.triggerTime;
      expect([t.month, t.day], [10, 25]);
      expect(t.hour, 9);
      expect(t.timeZoneOffset, const Duration(hours: 2));
    });
  });

  group('edge cases', () {
    test('no offsets means no reminders', () {
      expect(
        ReminderPlanner.plan(
          eventDate: DateTime(2026, 11, 17),
          daysBefore: {},
          location: athens,
          now: at(2026, 8, 19),
        ),
        isEmpty,
      );
    });

    test('ignores negative offsets rather than scheduling after the event',
        () {
      expect(
        ReminderPlanner.plan(
          eventDate: DateTime(2026, 11, 17),
          daysBefore: {-5},
          location: athens,
          now: at(2026, 8, 19),
        ),
        isEmpty,
      );
    });

    test('an offset of 0 means the day itself', () {
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2026, 11, 17),
        daysBefore: {0},
        location: athens,
        now: at(2026, 8, 19),
      );
      final t = planned.single.triggerTime;
      expect([t.month, t.day, t.hour], [11, 17, 9]);
    });

    test('honours a custom hour', () {
      final planned = ReminderPlanner.plan(
        eventDate: DateTime(2026, 11, 17),
        daysBefore: {1},
        location: athens,
        now: at(2026, 8, 19),
        hour: 18,
      );
      expect(planned.single.triggerTime.hour, 18);
    });
  });

  group('notification ids', () {
    test('are stable for the same input', () {
      expect(
        ReminderPlanner.notificationIdFor('abc123'),
        ReminderPlanner.notificationIdFor('abc123'),
      );
    });

    test('fit in a signed 32-bit int for Android', () {
      for (final id in ['a', 'reminder-1', 'f' * 64]) {
        final value = ReminderPlanner.notificationIdFor(id);
        expect(value, greaterThanOrEqualTo(0));
        expect(value, lessThan(2147483648));
      }
    });

    test('do not collide across many ids', () {
      final ids = List.generate(
        5000,
        (i) => ReminderPlanner.notificationIdFor('reminder-$i'),
      );
      expect(ids.toSet(), hasLength(ids.length));
    });
  });
}
