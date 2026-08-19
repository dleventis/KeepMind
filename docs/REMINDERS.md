# Reminders

## Core principle

"AI interprets. Deterministic software executes." (brief §10, verbatim.) An AI provider may propose a date and suggested reminder offsets; once a human confirms them, they become a plain structured `Reminder` row, and everything from that point on is deterministic Dart code with no AI involvement.

Implemented in Phase G:

- `domain/services/reminder_planner.dart` — pure logic. Turns a confirmed event date plus a set of "N days before" offsets into absolute instants. No I/O, no plugins, no clock of its own, so DST, month ends, leap years, and past offsets are all unit-testable.
- `data/services/reminder_scheduler.dart` — orchestration: plan, persist, register with the OS, and reconcile at launch.
- `data/notifications/local_notification_service.dart` — the platform plugin, behind an interface so the scheduler can be tested with a fake.

## Reminder record

```
id
memory_id          -- FK, ON DELETE CASCADE
trigger_time       -- absolute instant
timezone           -- IANA identifier
days_before        -- the offset this came from
notification_id    -- stable platform id (FNV-1a of the reminder id)
status             -- scheduled | elapsed | acknowledged
created_at
acknowledged_at
```

## What the platform will and will not tell us

This is the single most important constraint in the whole feature, and an earlier version of this design got it wrong.

**Neither iOS nor Android gives an app a delivery receipt for a local notification.** `flutter_local_notifications` provides a callback when the user *taps* a notification, and nothing at all when one is merely shown. So the app cannot distinguish "shown and ignored" from "never shown".

The status model reflects exactly that and claims nothing more:

- `scheduled` — registered with the OS, expected to fire.
- `elapsed` — its trigger time has passed, so we no longer expect it to fire. **Not** a claim that it failed, and not a claim that it succeeded.
- `acknowledged` — the user tapped it. The only delivery signal we actually get, so the only one we assert.

The original design had `delivered` and `missed`. Both were removed: nothing could ever set `delivered` truthfully, and `missed` would have libelled every reminder the user saw and swiped away.

## What "scheduled" does not mean

Scheduling with `flutter_local_notifications` is a *request* to the OS, not a guarantee. This design never treats "we called the scheduling API" as "the user will be reminded":

- **The database is the source of truth; the OS queue is a cache of it.** On every launch, `ReminderScheduler.reconcile()` re-reads every pending reminder and re-registers any the OS no longer has. Notifications get dropped by force stops, app updates, permission changes, and some OEM battery managers.
- **Reminders are persisted before they are registered.** If the process dies between the two, reconciliation puts it back. The reverse order would leave an OS-registered notification with no row behind it — invisible to the app forever.
- **Timezone-correct.** Each reminder stores an IANA zone and is resolved through `package:timezone`, so a DST transition or a change of device timezone doesn't silently move it. Reminders fire at 09:00 *civil* local time; a fixed clock hour is what a person expects, and it is what makes DST handling meaningful.
- **`package:timezone` cannot detect the device's zone** — it says so explicitly. `flutter_timezone` supplies the IANA name; without it `tz.local` is UTC and every reminder fires at the wrong hour.
- **iOS caps pending local notifications at 64.** Reconciliation registers the soonest first and stops at the cap, so the nearest reminders are never the ones dropped.
- **Offsets in the past are skipped, and the UI says so.** Asking for "7 days before" on something happening in three days schedules nothing for that offset; `SchedulingResult.skippedInPast` carries this to the UI so the user is told rather than left assuming three reminders were set.
- **Permission is requested contextually** — at first reminder creation, not on cold launch. On iOS you only get to ask once.

## Android specifics

`SCHEDULE_EXACT_ALARM` rather than `USE_EXACT_ALARM`: a date-based reminder tolerates slack, and Play policy restricts `USE_EXACT_ALARM` to alarm/timer-style apps. `exactAllowWhileIdle` so a reminder isn't swallowed by Doze on a phone left on a desk overnight — exactly when a 09:00 reminder is due. The plugin's boot receiver re-registers after a restart, but the app reconciles from the database at every launch rather than trusting it alone.
