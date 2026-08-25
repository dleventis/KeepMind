import 'package:timezone/timezone.dart' as tz;

/// One reminder the app intends to fire: an absolute instant, plus the
/// offset it came from so the UI can say "7 days before".
class PlannedReminder {
  const PlannedReminder({
    required this.triggerTime,
    required this.daysBefore,
    required this.timezoneName,
  });

  /// The absolute instant to fire at, resolved in a specific zone.
  final tz.TZDateTime triggerTime;

  final int daysBefore;

  /// IANA name of the zone [triggerTime] was resolved in, persisted
  /// alongside the reminder so a later reschedule can reproduce it.
  final String timezoneName;

  @override
  bool operator ==(Object other) =>
      other is PlannedReminder &&
      other.triggerTime == triggerTime &&
      other.daysBefore == daysBefore;

  @override
  int get hashCode => Object.hash(triggerTime, daysBefore);
}

/// Turns a confirmed event date into concrete reminder instants.
///
/// This is the deterministic half of the brief's core rule (§10): "AI
/// interprets. Deterministic software executes." No model is involved
/// here and none ever should be — by the time anything reaches this
/// class, a human has confirmed the date.
///
/// Pure logic with no I/O, no plugins, and no clock of its own ([now] is
/// injected), so the awkward cases — DST, month ends, leap years, offsets
/// that fall in the past — are all unit-testable without a device.
class ReminderPlanner {
  ReminderPlanner._();

  /// The brief's suggested defaults (§6): 30 days, 7 days, 1 day before.
  static const Set<int> defaultDaysBefore = {30, 7, 1};

  /// Reminders fire at 09:00 local rather than at the wall-clock time the
  /// user happened to save the memory — otherwise saving something at
  /// 03:00 means being woken at 03:00 a month later. A fixed civil hour
  /// is also what makes DST handling meaningful: "09:00 local on the day"
  /// stays 09:00 across a DST boundary, which is what a person expects.
  static const int defaultHour = 9;

  /// Plans reminders for [eventDate], skipping any that would already be
  /// in the past.
  ///
  /// [eventDate] is treated as a calendar date; its time component is
  /// ignored. [now] must be in [location] so the comparison is sound.
  /// Returns soonest-first.
  static List<PlannedReminder> plan({
    required DateTime eventDate,
    required Set<int> daysBefore,
    required tz.Location location,
    required tz.TZDateTime now,
    int hour = defaultHour,
  }) {
    final planned = <PlannedReminder>[];

    for (final days in daysBefore) {
      if (days < 0) continue;

      // TZDateTime normalizes out-of-range day values the same way
      // DateTime does, so `day - 30` correctly walks back across month
      // and year boundaries (and leap days) without manual arithmetic.
      final trigger = tz.TZDateTime(
        location,
        eventDate.year,
        eventDate.month,
        eventDate.day - days,
        hour,
      );

      // Scheduling into the past is meaningless: the OS would either
      // fire immediately or drop it. Silently skipping is correct, and
      // the UI tells the user which offsets actually applied.
      if (!trigger.isAfter(now)) continue;

      planned.add(
        PlannedReminder(
          triggerTime: trigger,
          daysBefore: days,
          timezoneName: location.name,
        ),
      );
    }

    planned.sort((a, b) => a.triggerTime.compareTo(b.triggerTime));
    return planned;
  }

  /// A stable 31-bit id derived from a reminder's string id, used as the
  /// platform notification id.
  ///
  /// Deliberately NOT `String.hashCode`: Dart makes no guarantee that it
  /// is stable across runs or platforms, so a reminder scheduled today
  /// could become impossible to cancel after a restart. FNV-1a is fully
  /// specified and implemented here, so the same string always yields the
  /// same id. Masked to 31 bits because Android notification ids are
  /// signed 32-bit ints.
  static int notificationIdFor(String reminderId) {
    var hash = 0x811c9dc5;
    for (final unit in reminderId.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }
}
