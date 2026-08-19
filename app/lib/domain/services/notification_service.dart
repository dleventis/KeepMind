import 'package:timezone/timezone.dart' as tz;

/// Platform notification delivery, behind an interface so the scheduler
/// can be tested without a device (brief §35). Implementation:
/// `data/notifications/local_notification_service.dart`.
abstract interface class NotificationService {
  /// Prepares the plugin and timezone database. Safe to call more than
  /// once.
  Future<void> initialize();

  /// Asks for notification permission (and, on Android 12+, exact-alarm
  /// permission). Returns false if the user declined.
  ///
  /// Called at the point the user creates their first reminder, not on
  /// cold launch — a permission prompt before the app has demonstrated
  /// why it needs one gets denied, and on iOS you only get to ask once.
  Future<bool> requestPermissions();

  /// True if notifications are currently permitted.
  Future<bool> hasPermission();

  Future<void> schedule({
    required int notificationId,
    required tz.TZDateTime triggerTime,
    required String title,
    required String body,
    String? payload,
  });

  Future<void> cancel(int notificationId);

  /// Platform-level ids currently scheduled. Used by reconciliation to
  /// detect reminders the OS has silently dropped.
  Future<Set<int>> pendingNotificationIds();
}
