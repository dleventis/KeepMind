# Architecture

See `docs/TECHNICAL_FOUNDATION_PLAN.md` for the full reasoning behind every choice on this page; this file is the shorter reference to come back to once the plan itself has been superseded by later phases.

## Layers

```
presentation/   screens + widgets, Riverpod providers for UI state
domain/         entities (MemoryObject, Reminder, Extraction) + repository interfaces
                 -- no Flutter or third-party package imports
data/           repository implementations: Drift database, secure storage,
                 file storage
ai/             AIProvider abstraction, AIRouter, provider implementations
                 (OpenAI / Anthropic / Gemini / Local)
core/           cross-cutting: app-level error types, theme, constants
```

Dependency direction: `presentation` depends on `domain`; `data` and `ai` depend on `domain` (they implement its interfaces) but `domain` never depends on them. Wiring happens through Riverpod providers registered in `presentation/providers/app_providers.dart` — this is the one place allowed to import both an interface and its concrete implementation.

## Why not full Clean Architecture

No dedicated use-case/interactor class per action. Repository interfaces plus Riverpod providers already give the two things Clean Architecture use-cases exist to provide here — testability (swap an implementation via provider override) and a clear boundary between "what the app does" and "how it's implemented" — without an extra class for every single-line operation. Revisit if/when a screen's business logic genuinely outgrows what a repository call plus a small controller class can express clearly.

## The core product loop, mapped to code

```
CAPTURE    → presentation/capture (Phase C)
UNDERSTAND → ai/ (OCR result → AIProvider.extractStructuredData) (Phase D/E/F)
CONFIRM    → presentation/confirm (Phase F)
STORE      → data/local/database (Phase B)
REMEMBER   → data/local/database + domain/entities/reminder.dart (Phase G)
NOTIFY     → data (ReminderScheduler, flutter_local_notifications) (Phase G)
RETRIEVE   → presentation/home, presentation/ask (Phase H)
ACT        → external to the app (opens the reminder, marks it acknowledged)
```

Every new feature should be placed by asking which stage of this loop it serves. If it doesn't serve one of these eight stages, it's probably scope creep (see the brief's design philosophy, section 4).
