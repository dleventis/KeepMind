import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/services/notification_service.dart';

/// flutter_local_notifications-backed delivery.
///
/// All the platform awkwardness lives here so `ReminderScheduler` stays
/// pure orchestration and can be tested with a fake.
class LocalNotificationService implements NotificationService {
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    this.onNotificationTapped,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Invoked with a reminder's payload (the memory id) when the user taps
  /// a notification. This is the *only* delivery signal either platform
  /// gives an app — there is no "was shown" callback — so it is also the
  /// only thing that can move a reminder to `acknowledged`.
  final void Function(String memoryId)? onNotificationTapped;

  /// The in-flight (or completed) initialization. Caching the Future
  /// rather than a bool makes concurrent callers share one initialization
  /// instead of both running it — `main()` and the first `schedule()`
  /// can otherwise race.
  Future<void>? _initialization;

  static const String _channelId = 'keepmind_reminders';
  static const String _channelName = 'Reminders';
  static const String _channelDescription =
      'Reminders for things you asked KeepMind to remember.';

  @override
  Future<void> initialize() => _initialization ??= _doInitialize();

  Future<void> _doInitialize() async {
    // The timezone database must be loaded before any TZDateTime is
    // constructed. `latest_all` rather than the trimmed 10-year build:
    // this app schedules years ahead (passports run 10 years) and a
    // truncated database would resolve those dates wrongly.
    tzdata.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      // package:timezone defaults local to UTC. Reminders would still
      // fire, just at the wrong civil hour, so this is degraded-but-
      // working rather than fatal.
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      // Permission is requested explicitly at first reminder creation
      // instead, so the prompt arrives with context (brief §25).
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _handleResponse,
    );
  }

  void _handleResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      onNotificationTapped?.call(payload);
    }
  }

  @override
  Future<bool> requestPermissions() async {
    await initialize();

    // iOS and macOS need *different* resolver types — asking for the iOS
    // one on macOS returns null, which would silently read as "permission
    // denied" and stop every reminder from being registered.
    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    if (Platform.isMacOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final notifications = await android?.requestNotificationsPermission();
      // Android 12+ additionally gates *exact* alarms. Without it the
      // schedule still works but may be delayed by the OS — acceptable
      // for a date-based reminder, so a refusal here is not fatal.
      await android?.requestExactAlarmsPermission();
      return notifications ?? false;
    }

    return false;
  }

  @override
  Future<bool> hasPermission() async {
    await initialize();
    if (Platform.isAndroid) {
      final enabled = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return enabled ?? false;
    }
    if (Platform.isIOS) {
      final options = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return options?.isEnabled ?? false;
    }

    if (Platform.isMacOS) {
      final options = await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return options?.isEnabled ?? false;
    }

    return false;
  }

  @override
  Future<void> schedule({
    required int notificationId,
    required tz.TZDateTime triggerTime,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();
    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: triggerTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // exactAllowWhileIdle so a reminder isn't swallowed by Doze on a
      // phone left on a desk overnight — which is exactly when a
      // 09:00 reminder is due.
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  @override
  Future<void> cancel(int notificationId) async {
    await initialize();
    await _plugin.cancel(id: notificationId);
  }

  @override
  Future<Set<int>> pendingNotificationIds() async {
    await initialize();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((p) => p.id).toSet();
  }
}
