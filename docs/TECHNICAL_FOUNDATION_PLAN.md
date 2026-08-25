# Mindkeep — Technical Foundation Plan

Status: Draft for review (Phase A)
Date: 2026-08-13
Owner: architecture (Claude, acting as lead architect per project brief)

This document is the first deliverable required by the Mindkeep master prompt (section 55). It answers the eighteen foundation questions, proposes an exact technology stack, and is followed by a repository skeleton and the smallest runnable app. Nothing here is final — it is meant to be argued with. Where a decision has a real alternative, the alternative and the reason it lost are recorded so the choice can be revisited later without re-litigating from scratch.

Versions below were checked against pub.dev and the Flutter docs on 2026-08-13 rather than assumed from training data (per rule 52 of the brief — do not invent package versions).

---

## 1. Cross-platform framework: Flutter

Flutter is the default the brief asks to strongly consider unless analysis reveals a blocker, and nothing in Mindkeep's requirement set is a blocker. The app needs camera capture, on-device OCR, local encrypted SQL storage, scheduled local notifications, secure credential storage, and background-safe reminder rescheduling — all of these have mature, actively maintained Flutter plugins on both iOS and Android. React Native was the alternative considered: its camera/file/notification plugin ecosystem is comparably mature, but Flutter's single-codebase rendering (no reliance on a JS bridge to native UI components) reduces a category of platform-inconsistency bugs that would otherwise cost QA time on a two-person-or-fewer team, and Dart's sound null safety plus code-gen tooling (drift, riverpod_generator, freezed) fits the "structured, validated data" emphasis of this app (sections 15–16 of the brief) better than TypeScript's more permissive interop with native modules. Decision: Flutter, stable channel.

## 2. Architecture pattern

A pragmatic three-layer architecture, not full Clean Architecture with use-case classes for every action — the brief explicitly warns against architecture astronautics (section 47). Layers:

- **presentation/** — screens and widgets, holding only UI state. Reads/writes through Riverpod providers.
- **domain/** — plain Dart entities (`MemoryObject`, `Reminder`, `Extraction`) and repository *interfaces*. No Flutter or package imports here, so domain logic stays testable without a widget tree or a database.
- **data/** — repository *implementations*: the Drift database, the AI provider clients, secure storage. This is the only layer allowed to know about SQL, HTTP, or platform channels.

A parallel **ai/** module holds the AI provider abstraction and router (section 14 of the brief calls this out as its own concern, so it gets its own top-level folder rather than living inside data/). Dependency direction is presentation → domain ← data/ai, wired together with Riverpod providers at app startup. This gets nearly all the testability benefit of Clean Architecture (swap a repository implementation for a mock without touching UI code) without the ceremony of use-case objects for single-line operations.

## 3. Local database: Drift over sqlite3

Drift (the actively maintained successor to Moor) generates type-safe Dart query code from table definitions, supports migrations with version numbers, and has first-class support for reactive streams — useful for a Home screen that needs to update live as reminders are confirmed. Alternative considered: raw `sqflite` with hand-written SQL. Rejected because hand-written SQL string queries are exactly the kind of thing that silently drifts out of sync with the schema as MemoryObject evolves (section 9 of the brief already flags this as a heterogeneous, evolving model). Drift's compile-time query checking catches that class of bug before it ships.

## 4. Encryption strategy

As of Drift 2.32+, the previously-recommended `sqlcipher_flutter_libs` package is officially deprecated ("no longer necessary," per Drift's own encryption docs) in favor of `NativeDatabase` backed by SQLite3MultipleCiphers, configured via a `PRAGMA key` statement in the database's `setup` callback, with the multi-cipher SQLite3 binary bundled through pubspec build hooks. This is the path this plan adopts. The encryption key itself is a 256-bit value generated with a cryptographically secure RNG on first launch and stored via `flutter_secure_storage`, which is backed by iOS Keychain and Android Keystore/EncryptedSharedPreferences — never written to disk in plaintext, never logged, never included in backups outside the OS's own secure-storage backup handling. If the key is unavailable (e.g., Keychain access denied, or a restore onto a new device without keychain migration), the app must fail safely into a "database locked" state rather than silently creating a new, empty encrypted database — losing a user's memories silently would be the single worst failure mode this app could have.

## 5. OCR approach

`google_mlkit_text_recognition` (ML Kit Text Recognition v2, currently 0.16.0) runs fully on-device on both iOS and Android — Google ships the model bundled with the plugin rather than calling a cloud API, so this satisfies the "prefer inexpensive/on-device OCR before cloud AI" principle in section 17 without needing two separate platform-specific OCR paths (Apple Vision on iOS, ML Kit on Android). Using one plugin for both platforms is a deliberate simplicity trade-off — Apple's on-device Vision framework is generally regarded as more accurate for iOS specifically, and is worth revisiting in Phase I once there's real accuracy data from ML Kit in the field. The OCR pipeline is: image → ML Kit text recognition → plain text → sent to the AI provider for semantic extraction. The original image is only sent to a (cloud) multimodal AI provider if the user has explicitly enabled that provider and the document isn't marked as a sensitivity category that blocks it (section 20).

## 6. Notification architecture

`flutter_local_notifications` (22.3.0) plus the `timezone` package for DST-aware, IANA-timezone-correct scheduling. Design principles, directly from section 10 of the brief: AI proposes a date, confirmed human input turns it into a structured `Reminder` row, and a deterministic `ReminderScheduler` service (plain Dart, testable without a device) is the only thing that ever calls the notification plugin. On every app launch, and after any device-reboot receiver fires on Android, the scheduler re-reads all pending reminders from the database and re-registers any that the OS may have dropped — notification scheduling is treated as best-effort at the OS level, so the source of truth is always the database row, never trust that "scheduled" implies "will fire." Delivery is not assumed: a reminder only moves from `scheduled` to `delivered` when the OS actually invokes the notification callback, which is logged back to the database. Android 12+ exact-alarm permission and iOS notification permission are requested contextually (at first reminder creation, not on first app launch) with a clear explanation screen, matching the "no jargon" UX principle in section 25.

## 7. AI provider abstraction

An abstract `AIProvider` interface in `ai/ai_provider.dart` exposing `analyzeText()`, `analyzeImage()`, `extractStructuredData()`, `answerMemoryQuery()`, `generateEmbedding()`, and capability flags `supportsVision()` / `supportsStructuredOutput()`, matching section 11 verbatim. An `AIRouter` selects the active provider from user settings and is the only class the rest of the app talks to — no screen or repository ever imports `OpenAIProvider` directly. For the first runnable milestone, only stub implementations exist (`OpenAIProvider`, `AnthropicProvider`, `LocalProvider`), each throwing a clear `UnimplementedError` — real HTTP integration is Phase E/F work, not Phase A.

## 8. Secure API-key storage

`flutter_secure_storage` (11.0.0), one entry per provider, keyed by a stable provider id (`openai`, `anthropic`, `gemini`). Never read into a long-lived in-memory singleton beyond the lifetime of a single request — pulled from secure storage at call time. No key is ever included in a log statement, crash report, or analytics event; `AppErrors` (section 33) are designed so their string representations cannot accidentally interpolate a raw key.

## 9. State management: Riverpod

`flutter_riverpod` (3.4.2). Chosen over Bloc (more ceremony per feature, worse fit for a small team) and plain `Provider` (Riverpod is its safer, compile-time-checked successor from the same author). Riverpod's provider graph is also a natural fit for the AI-router / repository wiring described above — repositories and the router are themselves providers, so swapping a mock repository into a widget test is a one-line override rather than a DI container reconfiguration. Code generation (`riverpod_generator`) is deferred until the provider count actually gets unwieldy; hand-written providers are simpler to read for the first milestone.

## 10. File storage architecture

Captured images and PDFs are written to the app's sandboxed documents directory (`path_provider`), one subfolder per `MemoryObject.id`. For MVP this relies on OS-level sandboxing and platform default-at-rest protections (iOS Data Protection is on by default for app-sandbox files; Android app-private storage is inaccessible to other apps without root). Per-file application-level encryption (a random key per attachment, itself stored via secure storage) is deferred to Phase I as a hardening step — the brief's own privacy hierarchy (section 18) treats "encrypted local database" as the Phase-A requirement and treats attachment encryption as part of the broader privacy-architecture pass, not the first milestone.

## 11. Does the MVP need a backend?

No. Phases A–I are fully local-first: no account, no server, no sync. This directly satisfies section 21 ("evaluate whether accounts are even necessary") and section 39 ("do not create a backend unless needed"). A backend becomes necessary only for Phase J (cross-device sync, encrypted backup, family sharing) and Phase K (subscription entitlement validation) — at that point Supabase is the leading candidate given its Postgres foundation, built-in row-level security (a good fit for a privacy-sensitive schema like `MemoryObject`), and lower lock-in than Firebase's proprietary data model, but that evaluation is explicitly out of scope for this document.

## 12. Repository structure

```
Mindkeep/                          (this repo)
├── README.md
├── LICENSE                        (placeholder — license not yet chosen)
├── .gitignore
├── .github/workflows/ci.yaml
├── docs/
│   ├── TECHNICAL_FOUNDATION_PLAN.md   (this file)
│   ├── ARCHITECTURE.md
│   ├── AI_PROVIDERS.md
│   ├── SECURITY.md
│   ├── PRIVACY.md
│   ├── DATABASE.md
│   ├── REMINDERS.md
│   └── DECISIONS.md                   (ADR log)
└── app/                            (the Flutter project)
    ├── pubspec.yaml
    ├── analysis_options.yaml
    ├── lib/
    │   ├── main.dart
    │   ├── app.dart
    │   ├── core/            (errors, theme, constants)
    │   ├── domain/           (entities, repository interfaces)
    │   ├── data/              (drift database, secure storage, repository impls)
    │   ├── ai/                 (AIProvider abstraction, router, provider stubs)
    │   └── presentation/        (screens, widgets, providers)
    ├── test/
    ├── android/   ← generated locally via `flutter create .` (see note below)
    └── ios/       ← generated locally via `flutter create .` (see note below)
```

A single Flutter app inside `app/` rather than a multi-package monorepo (e.g. Melos-managed packages) — splitting `domain`/`data`/`ai` into separate pub packages is a reasonable Phase I refactor once module boundaries have proven themselves in practice, but doing it on day one is exactly the kind of premature structure the brief warns against.

**Environment limitation, stated plainly:** this session's sandbox has outbound network access restricted to an allowlist that does not include `storage.googleapis.com` or `pub.dev`, so the Flutter SDK could not be downloaded here and `flutter create` / `flutter pub get` could not be run in this session. Everything under `lib/`, `test/`, and the `pubspec.yaml` is hand-authored to be correct, but the native `android/` and `ios/` platform folders are *generated* by the Flutter tool itself and were not fabricated — running `flutter create .` inside `app/` on your machine (with the `lib/`, `test/`, and `pubspec.yaml` already in place) will generate them without overwriting your Dart code. This is called out again in the README.

## 13. Major dependencies (versions verified 2026-08-13)

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | 3.4.2 | State management / DI |
| drift | 2.34.3 | Local SQL database (type-safe) |
| flutter_secure_storage | 11.0.0 | Keychain/Keystore-backed secret storage |
| google_mlkit_text_recognition | 0.16.0 | On-device OCR |
| flutter_local_notifications | 22.3.0 | Deterministic local reminders |
| timezone | latest compatible | DST/IANA-correct scheduling |
| path_provider | latest compatible | Sandboxed file storage paths |
| camera / image_picker | latest compatible | Capture screen (Phase C) |
| mocktail | latest compatible | Test doubles for AIProvider/repositories |

Exact `^x.y.z` constraints are pinned in `app/pubspec.yaml`; run `flutter pub outdated` locally before Phase B starts, since pub.dev could not be reached from this sandbox to lock the very latest patch versions at the moment of writing.

## 14. Testing strategy

Unit tests for domain entities and the (pure-Dart) `ReminderScheduler`; repository tests against an in-memory Drift database (`NativeDatabase.memory()`); `AIProvider` tests exclusively against mock implementations via `mocktail` — the brief is explicit that normal tests must never require a live API call (section 35). Widget tests for each screen, starting with a test asserting the Home screen renders "Nothing you need to remember right now." and the capture CTA. Integration tests (`integration_test` package) and migration tests are added starting Phase B once there's a real schema to migrate.

## 15. Security threat model (initial pass)

Mapped directly from section 43: a stolen/unlocked phone is mitigated by OS biometric app-lock (Phase I) plus at-rest DB encryption; a malicious co-installed app is mitigated by never writing secrets outside Keychain/Keystore-backed storage; a compromised device backup is mitigated by relying on the OS's own encrypted-backup handling of Keychain/Keystore entries rather than a custom backup path; a leaked provider API key is mitigated by BYOK (Mindkeep's own servers never see it) and secure-storage-only persistence; database extraction from a rooted/jailbroken device is mitigated by SQLite3MultipleCiphers encryption; malicious or booby-trapped documents and prompt injection embedded in OCR'd text are mitigated by the system/document separation described in section 44 — AI prompts are constructed so extracted document text is passed as clearly-delimited untrusted data, never concatenated into the instruction portion of a prompt, and the structured-output validator (section 15/16 of the brief) rejects any AI response that doesn't conform to the expected schema before it reaches application logic.

## 16. Development milestones

Phases A–L as specified in the brief, unchanged: A (architecture + repo — this document and the skeleton that follows), B (local memory CRUD), C (camera/file ingestion), D (OCR), E (AI provider abstraction — live implementations), F (structured extraction), G (reminder engine), H (Ask Mindkeep), I (security/privacy hardening), J (sync/account), K (monetization), L (beta). Each phase is a separate development step per the section-51 procedure (goal → architecture decision → files affected → implement → tests → manual verification → next step) — this plan does not attempt to pre-design phases E onward in detail; that happens when each phase starts.

## 17. Technical risks

OCR accuracy on low-quality photos (angled documents, glare, handwriting) will be the single biggest driver of user trust or distrust — the confidence/confirmation UX in section 16 exists specifically to contain this risk rather than eliminate it. iOS background execution limits constrain how aggressively the app can proactively re-verify that scheduled notifications are still registered; the reboot-safe rescheduling design in section 6 above is the mitigation, not a guarantee. SQLite3MultipleCiphers is a newer recommended path than the previous SQLCipher plugin and has a smaller track record in production Flutter apps — worth a short spike in Phase B to confirm it behaves identically across a real iOS device, a real Android device, and CI before committing further. App Store review risk exists around camera/photo-library permission justification text and, later, around subscription entitlement wording — both are UX-copy risks more than engineering risks, but worth flagging early since App Store rejections cost calendar time, not developer time. BYOK key-entry UX (asking a non-technical user to paste an API key) is a real adoption risk for the AI-provider-independence goal — the "Ask Mindkeep" and confirmation screens should be designed so the app is still meaningfully useful (manual CRUD, physical-location memories, local reminders) with zero AI provider connected, so a user isn't blocked from any value until they've configured a key.

## 18. Estimated MVP complexity

The section-50 first milestone (open app → photograph a document → OCR → AI extraction → confirm → store → schedule notification → retrieve) is realistically medium-high complexity for a solo or near-solo developer: none of the individual pieces are exotic, but the milestone requires seven separate subsystems (capture, OCR, one live AI provider, structured validation, local encrypted persistence, the reminder scheduler, and a confirmation UI) to all work together correctly on both platforms before it's demonstrably "working." A reasonable estimate is 3–5 focused development sessions (per the section-51 one-step-at-a-time procedure) to get from this skeleton to that first working milestone, assuming no major surprises from SQLite3MultipleCiphers or ML Kit's iOS behavior.

---

## Summary of the proposed stack

Flutter (stable) · Riverpod · Drift + SQLite3MultipleCiphers · flutter_secure_storage · google_mlkit_text_recognition · flutter_local_notifications + timezone · no backend for MVP · local-first, BYOK AI, structured-output validation, deterministic reminder engine decoupled from AI.

Proceeding to the repository skeleton and the smallest runnable app now, per section 55 of the brief, unless you'd like to redirect any of the above first.
