/// Lifecycle of a reminder.
///
/// Deliberately models only what the platform can actually tell us.
/// Neither iOS nor Android gives an app a *delivery* receipt for a local
/// notification — flutter_local_notifications exposes a callback when the
/// user **taps** one, and nothing at all when one is merely shown. An
/// earlier version of this enum had `delivered` and `missed` states; they
/// were removed because nothing could ever set them truthfully, and
/// "missed" would have libelled every reminder the user saw and swiped
/// away. See docs/REMINDERS.md.
enum ReminderStatus {
  /// Registered with the OS and expected to fire.
  scheduled,

  /// Its trigger time has passed. Whether the user actually saw it is
  /// genuinely unknown to us — this state says "we no longer expect it to
  /// fire", not "it failed".
  elapsed,

  /// The user tapped the notification. The one delivery signal the
  /// platform does give us, so the only one we claim.
  acknowledged,
}

/// A deterministic reminder tied to a confirmed memory. Once created,
/// nothing about firing it involves an AI call — brief §10: "AI
/// interprets. Deterministic software executes."
class Reminder {
  const Reminder({
    required this.id,
    required this.memoryId,
    required this.triggerTime,
    required this.timezone,
    required this.status,
    required this.createdAt,
    required this.daysBefore,
    required this.notificationId,
    this.acknowledgedAt,
  });

  final String id;
  final String memoryId;

  /// The absolute instant to fire at. Stored together with [timezone]
  /// (an IANA name) rather than as a naive local time, so a DST
  /// transition or a change of device timezone doesn't silently move it.
  final DateTime triggerTime;
  final String timezone;

  /// How many days before the memory's event date this fires — kept so
  /// the UI can say "7 days before" without recomputing, and so a
  /// reschedule after an edited date can reproduce the user's choice.
  final int daysBefore;

  /// Stable platform notification id (see
  /// `ReminderPlanner.notificationIdFor`). Persisted rather than derived
  /// at call time so cancellation still works if that derivation ever
  /// changes.
  final int notificationId;

  final ReminderStatus status;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;

  Reminder copyWith({ReminderStatus? status, DateTime? acknowledgedAt}) {
    return Reminder(
      id: id,
      memoryId: memoryId,
      triggerTime: triggerTime,
      timezone: timezone,
      status: status ?? this.status,
      createdAt: createdAt,
      daysBefore: daysBefore,
      notificationId: notificationId,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    );
  }
}
