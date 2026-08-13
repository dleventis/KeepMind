# Database

## Engine

Drift (2.34.3) over `NativeDatabase`, encrypted via SQLite3MultipleCiphers rather than the now-deprecated `sqlcipher_flutter_libs` (see ADR-0002 in `docs/DECISIONS.md`). Encryption key: 256-bit, generated with a secure RNG on first launch, stored via `flutter_secure_storage`.

## Schema (Phase A skeleton — not yet finalized)

The brief's proposed `MemoryObject` schema (brief §9) is a reasonable starting point but is explicitly flagged there as something to critique, not implement blindly. This skeleton defines the Drift table shape in `app/lib/data/local/database/app_database.dart` with the core fields (`id`, `title`, `description`, `category`, `sourceType`, `createdAt`, `updatedAt`, `eventDate`, `confidenceScore`, `confirmationStatus`) plus a `structuredData` JSON column for the heterogeneous, category-specific fields the brief calls out (policy numbers, vehicle details, amounts, currencies, etc.) — normalizing every possible field into its own column would produce a very wide, mostly-null table for a genuinely heterogeneous object type. Full normalization is reserved for fields every memory type shares and that are queried/filtered/sorted on directly (dates, category, confirmation status); everything else lives in the JSON blob until a specific query need proves it should be promoted to a real column.

A `Reminder` table (Phase G) references `MemoryObject` by id and is deliberately separate from the notification-scheduling record — see `docs/REMINDERS.md`.

## Migrations

Drift's schema versioning (`schemaVersion` + `MigrationStrategy`) from day one, even though the Phase A schema is version 1. Every future column/table change ships as an explicit migration step with a corresponding migration test, per the brief's testing requirements (§35).

## Full-text search

Deferred until Phase H (Ask KeepMind); Drift supports SQLite FTS5 virtual tables when that's needed, which is preferred over pulling in an external search dependency for the MVP.
