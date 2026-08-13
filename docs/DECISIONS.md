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

## ADR-0003: Hand-rolled local IDs instead of the `uuid` package

**Date:** 2026-08-13
**Status:** Accepted

**Context:** Phase B (local memory CRUD) needs a way to generate memory/reminder IDs. The obvious choice is the `uuid` package, but every dependency added in this sandbox has to be taken on faith until `flutter pub get` can actually run against pub.dev locally (still blocked — see ADR-0001's environment note).

**Decision:** `core/utils/id_generator.dart` generates a 128-bit random hex string via `Random.secure()` instead of adding a new dependency. Not an RFC-4122 UUID, just an unguessable local identifier — sufficient for a single-user local database.

**Consequences:** One fewer unverified dependency to check locally. Revisit and switch to the `uuid` package (or whatever a Phase J sync backend expects) once cross-device sync makes a standard UUID format actually matter — not a hill to defend past Phase B.

## ADR-0004: `@DataClassName` on Drift tables to avoid a domain/persistence name collision

**Date:** 2026-08-13
**Status:** Accepted

**Context:** Drift's default naming singularizes a table class `MemoryObjects` into a generated row data class literally called `MemoryObject` — which collides with the domain entity `MemoryObject` in `domain/entities/memory_object.dart`. Caught by manual review (this sandbox cannot run `build_runner` or `dart analyze` to catch it automatically — see ADR-0001's environment note); would otherwise have surfaced as a confusing import/type error only once someone ran `build_runner` locally.

**Decision:** `@DataClassName('MemoryObjectRow')` and `@DataClassName('ReminderRow')` on the two Drift tables in `app_database.dart`, so the generated row types never share a name with a domain entity.

**Consequences:** `data/repositories/memory_repository_drift_impl.dart` maps between `MemoryObjectRow` (persistence) and `MemoryObject` (domain) explicitly — this mapping boundary is exactly what `docs/ARCHITECTURE.md` already calls for, so this decision reinforces the existing layering rather than adding a new concern.

<!-- Future ADRs go below this line, oldest first. -->
