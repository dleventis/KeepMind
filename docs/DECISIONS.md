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

## ADR-0005: image_picker for camera capture, not the `camera` package

**Date:** 2026-08-18
**Status:** Accepted

**Context:** Phase C needs photo capture. The `camera` package gives an in-app preview with full frame control; `image_picker` hands off to the OS camera app and returns a file.

**Decision:** Use `image_picker` for both camera and gallery. The `camera` dependency is removed.

**Consequences:** No custom viewfinder, no document edge-detection or auto-capture — the user takes a normal photo. In exchange: no `CameraController` lifecycle to manage across app backgrounding, no manual orientation/EXIF handling, one dependency instead of two, and a smaller permission and App Store review surface. Given the Shipaton deadline (see below), that trade is clearly correct for now. A custom camera with edge detection is a genuine post-launch UX improvement, not a launch blocker.

## ADR-0006: Deterministic date extraction before any AI

**Date:** 2026-08-18
**Status:** Accepted

**Context:** The confirmation screen is far more useful if it can suggest dates found in a document. The obvious path is to wait for Phase E/F (live AI extraction), but that leaves Phases C/D with OCR text and nothing done with it.

**Decision:** `domain/services/date_candidate_finder.dart` finds dates in OCR text using pattern matching — pure Dart, no network, no model. Ambiguous numeric dates (`03/04/2026`) produce *two* candidates, one per reading, and the user picks. Nothing is ever auto-selected.

**Consequences:** The app does something genuinely useful with a photographed document before any AI provider is configured, and keeps working for a user who never configures one. Directly follows the brief's rule against using an LLM where deterministic code is correct (§24, §53) and its instruction never to assume MM/DD/YYYY (§37). Semantic extraction — knowing *which* date is the expiry, and pulling out provider and policy number — still needs Phase E/F and layers on top of this rather than replacing it. Limitation: English month names only; localized names are an i18n task.

## ADR-0007: iOS deployment target raised to 15.5 for ML Kit

**Date:** 2026-08-18
**Status:** Accepted

**Context:** `google_mlkit_text_recognition` 0.16.0 requires an iOS deployment target of 15.5. Flutter's generated project targets 15.0, so `pod install` fails without a change.

**Decision:** Raise the iOS deployment target to 15.5 (Podfile `platform :ios, '15.5'` plus a `post_install` hook applying it to every pod target, and `IPHONEOS_DEPLOYMENT_TARGET` in the Xcode project).

**Consequences:** Drops support for iOS 15.0–15.4. In practice that is a negligible share of devices, and on-device OCR is the core of the product — a version floor is a fair price. Android's `minSdk` (21 for ML Kit) is already satisfied by Flutter's default.

<!-- Future ADRs go below this line, oldest first. -->
