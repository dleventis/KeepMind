/// See docs/REMINDERS.md — "scheduled" is a request to the OS, never
/// assumed to mean "delivered."
enum ReminderStatus { scheduled, delivered, acknowledged, missed }

/// A deterministic reminder tied to a confirmed [MemoryObject]. Once
/// created, nothing about firing this reminder involves an AI call —
/// see brief section 10, "AI interprets. Deterministic software executes."
class Reminder {
  const Reminder({
    required this.id,
    required this.memoryId,
    required this.triggerTime,
    required this.timezone,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    this.acknowledgedAt,
  });

  final String id;
  final String memoryId;

  /// Stored with an explicit [timezone] (IANA identifier) rather than a
  /// naive local time, so DST transitions and device timezone changes
  /// don't silently shift when this actually fires.
  final DateTime triggerTime;
  final String timezone;

  final ReminderStatus status;
  final DateTime createdAt;

  /// Only ever set when the OS actually invokes the notification
  /// callback — never optimistically set at scheduling time.
  final DateTime? deliveredAt;
  final DateTime? acknowledgedAt;
}
