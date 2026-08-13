# Privacy

## Local-first hierarchy

```
LOCAL DEVICE
  ↓ encrypted local database (Drift + SQLite3MultipleCiphers)
  ↓ optional encrypted sync (Phase J, not yet built)
  ↓ external AI only when explicitly required and disclosed
```

## Privacy modes (planned, not yet implemented in this skeleton)

- **Local Mode** — everything possible stays on device; no AI provider connected; OCR is already fully on-device regardless of mode.
- **Connected AI Mode** — selected content is transmitted to the user's chosen, user-configured AI provider, with per-provider disclosure before the first send and a persistent choice of "always allow this provider / ask every time / never send sensitive documents" (brief §19).

## Sensitivity categories

`MemoryObject.sensitivity` will support at minimum: `NORMAL`, `PERSONAL`, `FINANCIAL`, `MEDICAL`, `IDENTITY`. Rules for which categories can be auto-sent to cloud AI providers without an extra confirmation step are a Phase I product decision, not an engineering default — until that decision is made, the safe default is to always ask.

## What KeepMind never does

Silently sends document content to analytics. Assumes a date it isn't confident about. Requires a cloud account for core local functionality. Reuses developer-owned AI credentials to process user documents without explicit, disclosed consent.

## GDPR considerations (tracked here, implemented starting Phase I)

Data minimization, explicit consent before first external AI transmission, local data export, local and cloud deletion, retention controls, and a privacy policy are all required before any EU-facing release. None of this is implemented in the Phase A skeleton; tracked here so it isn't forgotten once sync/accounts (Phase J) make it more urgent.
