# KeepMind — Flutter app

See the repository root `README.md` for how to generate the missing `android/`
and `ios/` platform folders locally, and `../docs/` for architecture,
security, privacy, database, and reminders documentation.

## Layout

```
lib/
  main.dart              entry point
  app.dart                MaterialApp + root routing
  core/                    errors, theme, constants (cross-cutting)
  domain/                  entities + repository interfaces (no Flutter imports)
  data/                    Drift database, secure storage, repository impls
  ai/                      AIProvider abstraction, router, provider stubs
  presentation/            screens, widgets, Riverpod providers
test/
  widget/                  widget tests
```

## Running

```
flutter create . --project-name keepmind --org com.keepmind
flutter pub get
flutter run
```

## Testing

```
flutter test
```
