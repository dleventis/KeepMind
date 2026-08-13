# KeepMind

> Send it to KeepMind now. Remember it when it matters.

KeepMind is a personal prospective-memory application: capture a document, screenshot, or thought in a few seconds, and let KeepMind extract the dates, amounts, and actions that matter, then remind you deterministically when it's time to act. Names and taglines in this repo are provisional.

This repository is at **Phase A** (architecture + repository skeleton) of the development plan in [`docs/TECHNICAL_FOUNDATION_PLAN.md`](docs/TECHNICAL_FOUNDATION_PLAN.md). Nothing here is production-ready; the app currently boots to a single static Home screen.

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

Phase A only: architecture decisions, repository skeleton, and the smallest runnable UI (`KeepMind` / `Nothing you need to remember right now.` / `+ Remember something`). See `docs/DECISIONS.md` for the running architecture decision log and the phase plan for what comes next.

## License

Not yet chosen — see `LICENSE`.
