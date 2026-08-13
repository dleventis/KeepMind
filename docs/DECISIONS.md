# Architecture Decision Records

Format: each ADR is short — context, decision, consequences. Superseded ADRs are marked, not deleted.

## ADR-0001: Technical foundation for KeepMind

**Date:** 2026-08-13
**Status:** Accepted

**Context:** KeepMind needs a cross-platform mobile stack, local database, encryption approach, OCR approach, notification architecture, AI provider abstraction, secure key storage, state management, and a decision on whether an MVP backend is required. Full reasoning is in `docs/TECHNICAL_FOUNDATION_PLAN.md`.

**Decision:** Flutter (stable channel); layered presentation/domain/data + ai architecture; Drift over `NativeDatabase` with SQLite3MultipleCiphers for the encrypted local database; `flutter_secure_storage` for the DB encryption key and BYOK provider API keys; `google_mlkit_text_recognition` for on-device OCR on both platforms; `flutter_local_notifications` + `timezone` for deterministic, reboot-safe local reminders; Riverpod for state management/DI; no backend for the MVP (Phases A–I are fully local-first).

**Consequences:** The app works fully offline until a user explicitly connects an AI provider. Reminder reliability depends on a database-is-source-of-truth rescheduling design rather than trusting the OS's notification scheduler in isolation. `android/` and `ios/` platform folders must be generated locally via `flutter create .` since this session's sandbox could not reach the Flutter SDK download host or pub.dev.

## ADR-0002: sqlcipher_flutter_libs rejected in favor of SQLite3MultipleCiphers

**Date:** 2026-08-13
**Status:** Accepted

**Context:** The original brief suggested "SQLCipher or an equivalent." At the time of writing, Drift's own documentation states `sqlcipher_flutter_libs` is no longer necessary as of Drift 2.32+ and recommends `NativeDatabase` backed by SQLite3MultipleCiphers (via pubspec build hooks) with the key set through a `PRAGMA key` statement in the database `setup` callback.

**Decision:** Use `NativeDatabase` + SQLite3MultipleCiphers, not `sqlcipher_flutter_libs`.

**Consequences:** This is a newer, less battle-tested path in production Flutter apps than the older SQLCipher plugin. Flagged as a risk in the foundation plan (§17) — worth a short verification spike early in Phase B on real iOS and Android devices before other work builds on top of it.

<!-- Future ADRs go below this line, oldest first. -->
