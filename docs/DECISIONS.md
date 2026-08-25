# Architecture Decision Records

Format: each ADR is short — context, decision, consequences. Superseded ADRs are marked, not deleted.

## ADR-0001: Technical foundation for Mindkeep

**Date:** 2026-08-13
**Status:** Accepted

**Context:** Mindkeep needs a cross-platform mobile stack, local database, encryption approach, OCR approach, notification architecture, AI provider abstraction, secure key storage, state management, and a decision on whether an MVP backend is required. Full reasoning is in `docs/TECHNICAL_FOUNDATION_PLAN.md`.

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

## ADR-0008: Free tier capped at 10 memories; premium removes the cap

**Date:** 2026-08-25
**Status:** Accepted

**Context:** Shipaton requires the RevenueCat SDK to power at least one real purchase, so the app needs a paid tier before 30 September. The brief warns against baking a pricing model into code (§41) and against dark patterns (§53). Candidates considered: gating photo capture + OCR, gating the number of reminders, a pure tip jar, and capping stored memories.

**Decision:** Free = up to 10 active memories. Premium = unlimited. Everything else — photo capture, OCR, date extraction, all three reminder offsets — stays free at every tier.

**Consequences:** Gating capture/OCR was rejected because a reviewer or judge on the free tier would never see what makes the product interesting. Gating reminders was rejected outright: reminders *are* the product promise, so limiting them edges into the dark patterns the brief forbids. A tip jar was rejected as giving no real revenue signal. The cap is enforced at the *capture entry point*, not on save, so a user who has run out is told before they photograph a document and fill in a form. Critically, the cap applies only to **creating** memories — reading, editing, and deleting existing ones is never gated, including for a lapsed subscriber sitting over the limit. Holding someone's own passport expiry hostage to a renewal is not a thing this app will do. `FreeTierLimits` is pure functions so all of this is unit-tested.

## ADR-0009: iOS only for the Shipaton submission

**Date:** 2026-08-25
**Status:** Accepted

**Context:** Shipaton requires the app to be genuinely live on a store by 30 Sept 2026. A new Google Play personal account cannot publish to production until it has run a closed test with 12 testers opted in *continuously* for 14 days, followed by up to 7 days of production-access review — up to 21 days of unavoidable wall-clock time, on top of ID verification. With ~36 days left and no Play account yet, closed testing would have had to be running by around 9 September.

**Decision:** Ship iOS only for the contest. Android is deferred until after 30 September.

**Consequences:** Removes the single tightest constraint in the plan and frees the remaining weeks for the app itself; Apple review is typically 24–48 hours, leaving room for a rejection and resubmission. Nothing in the codebase becomes iOS-specific — Flutter, Drift, ML Kit, and flutter_local_notifications all remain cross-platform, and the Android manifest work from Phase G stays in place — so Android is a store-logistics task later, not a re-engineering one. Cost: no Android users during the contest, and the Play testing clock still has to be started from scratch afterwards.

## ADR-0010: Export compliance — the app is not in Apple's documentation-free category

**Date:** 2026-08-25
**Status:** Open — decision required before the submission build

**Context:** The encrypted database (ADR-0002) uses SQLite3MultipleCiphers,
a third-party C library compiled into the binary, keyed via `PRAGMA key`.
Apple's export compliance reference states that the only category needing
no documentation in App Store Connect is "Your app uses encryption limited
to that within the Apple operating system." Mindkeep does not qualify: it
ships its own crypto rather than calling CryptoKit or relying solely on iOS
Data Protection.

Apple further states that a **French encryption declaration form is
required if the app is distributed on the App Store in France**, and lists
Secure Storage as a main item of French control — which is precisely what
this app is.

**Options:**

1. **Exclude France for 1.0.** Removes the French declaration requirement
   per Apple's own wording, costs one market with no users in it yet, and
   is reversible once the paperwork is done.
2. **File the French declaration** and ship there from day one. More work
   before a deadline that is already tight.
3. **Drop the bundled cipher** and rely on iOS Data Protection
   (`NSFileProtectionComplete`) alone, which would put the app in the
   documentation-free category. Rejected as a v1 move: it reverses
   ADR-0002, weakens the at-rest story the privacy policy and App Store
   description both make, and does not carry over to Android later.

**Decision:** Pending. Whichever is chosen, the value of
`ITSAppUsesNonExemptEncryption` in `ios/Runner/Info.plist` is an export
determination signed by the developer, not an engineering default, and is
deliberately left unset until that determination is made.

**Consequences:** Until the key is set, every upload asks the export
questions interactively, and the answers attach to that build. Build 1 was
answered ad hoc and is a throwaway; the submission build must carry a
considered answer.

<!-- Future ADRs go below this line, oldest first. -->
