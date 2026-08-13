# Reminders

## Core principle

"AI interprets. Deterministic software executes." (brief §10, verbatim.) An AI provider may propose a date and suggested reminder offsets; once a human confirms them, they become a plain structured `Reminder` row, and everything from that point on is deterministic Dart code with no AI involvement.

## Reminder record

```
reminder_id
memory_id
trigger_time      -- stored with explicit timezone, not assumed local
timezone           -- IANA identifier, via the `timezone` package
type
status             -- scheduled | delivered | acknowledged | missed
created_at
delivered_at
acknowledged_at
```

## What "scheduled" does not mean

Scheduling a notification with `flutter_local_notifications` is a request to the OS, not a guarantee. This design never treats "we called the scheduling API" as equivalent to "the user will see this." Concretely:

- On every app launch, and on Android's boot-completed broadcast, the app re-reads every `scheduled` reminder from the database and re-registers it with the OS. The database is the source of truth; the OS's internal notification queue is not trusted to have survived a reboot, an app update, or a force-stop.
- `delivered_at` is only set when the OS actually invokes the notification callback — never optimistically set at scheduling time.
- Timezone changes and DST transitions are handled by storing an explicit IANA timezone per reminder and recomputing the absolute trigger instant through the `timezone` package rather than storing a naive local time that could shift meaning after a DST boundary.
- Notification permission (iOS) and exact-alarm permission (Android 12+) are requested contextually, at the point the user creates their first reminder, with plain-language copy — not on cold app launch before the user has any reason to grant it.

## What's in this skeleton vs. later

Phase A ships none of this yet — only the architectural placeholder (`domain/entities/reminder.dart`) and this document. The scheduler itself, the Drift `Reminder` table, and the boot-receiver wiring are Phase G work.
