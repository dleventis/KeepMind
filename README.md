# Mindkeep

> Send it to Mindkeep now. Remember it when it matters.

Mindkeep is a personal prospective-memory application: capture a document, screenshot, or thought in a few seconds, and let Mindkeep extract the dates, amounts, and actions that matter, then remind you deterministically when it's time to act. Names and taglines in this repo are provisional.

This repository is at **Phase B** (local memory CRUD) of the development plan in [`docs/TECHNICAL_FOUNDATION_PLAN.md`](docs/TECHNICAL_FOUNDATION_PLAN.md). Nothing here is production-ready; the app currently supports typing in a memory, viewing/editing/deleting it, and persisting it in the encrypted local database — no camera, OCR, AI extraction, or reminders yet.

## Repository layout

- `docs/` — architecture, security, privacy, database, reminders, AI-provider, and decision-log documentation. Start with `TECHNICAL_FOUNDATION_PLAN.md`.
- `app/` — the Flutter application (see `app/README.md`).

## Getting the app running locally

This skeleton was authored in an environment without access to the Flutter SDK or pub.dev, so the Dart source and `pubspec.yaml` are hand-written but the native `android/` and `ios/` platform folders (which the Flutter tool generates, not something safe to hand-fabricate) are **not yet present**. To get a runnable app:

```bash
cd app
flutter create . --project-name keepmind --org com.keepmind   # generates android/ and ios/ without touching lib/
flutter pub get
flutter run
```

If `flutter create .` prompts about overwriting existing files, it will not touch `lib/`, `test/`, or `pubspec.yaml` unless you explicitly confirm an overwrite — review its output before confirming any overwrite prompt.

## Status

- **Phase A** — architecture decisions, repository skeleton, smallest runnable UI.
- **Phase B** — local memory CRUD: manual "type it in" capture (`presentation/capture`), a memory list on Home, view/edit/delete (`presentation/memory_detail`), all persisted through the real Drift-backed repository (`data/repositories/memory_repository_drift_impl.dart`). Camera/photo/document capture, OCR, and AI extraction are still ahead (Phases C–F); reminders are Phase G.

See `docs/DECISIONS.md` for the running architecture decision log (ADR-0001 through ADR-0004) and the phase plan for what comes next.

**Still unverified locally:** this repo has never been compiled — see the environment note in `docs/DECISIONS.md` (ADR-0001). Run `flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter test` after generating the platform folders below; that build_runner step is required for Phase B specifically, since `data/local/database/app_database.dart` has a `part 'app_database.g.dart'` that doesn't exist yet in this delivery.

## License

Not yet chosen — see `LICENSE`.
