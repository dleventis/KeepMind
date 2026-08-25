import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'presentation/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ProviderScope roots the Riverpod graph — repositories, the AI router,
  // the database, and the reminder scheduler are all wired as providers
  // in app_providers.dart rather than constructed ad hoc in widgets.
  final container = ProviderContainer();

  // Load the timezone database and set up notifications before anything
  // can schedule a reminder.
  await container.read(notificationServiceProvider).initialize();

  // Entitlements are initialized without awaiting: the store can be slow
  // or unreachable, and the app must open regardless. Until it answers,
  // the user is treated as free tier — which is fully usable, so being
  // briefly wrong costs them nothing.
  unawaited(container.read(entitlementServiceProvider).initialize());

  // Re-register anything the OS dropped while we weren't running, and
  // retire reminders whose moment has passed. The database is the
  // source of truth; the OS queue is only a cache of it (see
  // docs/REMINDERS.md). Deliberately not awaited into the first frame —
  // a slow reconcile must never delay app launch.
  unawaited(_reconcileReminders(container));

  runApp(
    UncontrolledProviderScope(container: container, child: const MindkeepApp()),
  );
}

Future<void> _reconcileReminders(ProviderContainer container) async {
  try {
    // Memories are loaded and passed in so re-registered notifications
    // keep their real title. Without them every reminder the OS dropped
    // would come back as a useless "Mindkeep reminder" — precisely the
    // path reconciliation exists to rescue.
    final memories = await container
        .read(memoryRepositoryProvider)
        .watchAll()
        .first;
    await container
        .read(reminderSchedulerProvider)
        .reconcile(memoriesById: {for (final m in memories) m.id: m});
  } catch (_) {
    // Reconciliation is best-effort. Failing it must never prevent the
    // app from opening — the user's memories are still readable, and the
    // next launch tries again.
  }
}
