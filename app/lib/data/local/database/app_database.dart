import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../secure/secure_key_store.dart';

part 'app_database.g.dart';

/// Core memory table. Deliberately not a 1:1 port of the brief's proposed
/// schema — see docs/DATABASE.md for why heterogeneous, category-specific
/// fields live in [structuredData] (JSON) rather than as dozens of
/// mostly-null columns.
///
/// `@DataClassName('MemoryObjectRow')`: without this, Drift's default
/// singularization of `MemoryObjects` generates a row class literally
/// named `MemoryObject`, which collides with the domain entity of the
/// same name in `domain/entities/memory_object.dart`. Renaming the
/// generated row type avoids that collision at the one place
/// (`data/repositories/memory_repository_drift_impl.dart`) that imports
/// both.
@DataClassName('MemoryObjectRow')
class MemoryObjects extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()();
  TextColumn get sourceType => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get eventDate => dateTime().nullable()();
  RealColumn get confidenceScore => real().nullable()();

  /// Stored as an int index into ConfirmationStatus — see
  /// domain/entities/memory_object.dart for the enum this mirrors.
  IntColumn get confirmationStatus => integer()();
  IntColumn get sensitivity => integer().withDefault(const Constant(0))();

  /// JSON-encoded `Map<String, Object?>` — category-specific fields.
  /// (Backticked: bare angle brackets are parsed as HTML in doc comments.)
  TextColumn get structuredData => text().withDefault(const Constant('{}'))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  /// Local filesystem path to the captured image, if any (Phase C).
  TextColumn get sourceUri => text().nullable()();

  /// Verbatim OCR output (Phase D). Untrusted input — see
  /// docs/SECURITY.md.
  TextColumn get rawText => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Scheduled reminders (Phase G). Deliberately separate from the
/// platform notification queue, which is treated as a cache of this
/// table rather than a source of truth. See docs/REMINDERS.md.
@DataClassName('ReminderRow')
class Reminders extends Table {
  TextColumn get id => text()();

  /// `onDelete: KeyAction.cascade` so deleting a memory cannot leave
  /// reminders pointing at a row that no longer exists. Enforced only
  /// because `PRAGMA foreign_keys = ON` is set in beforeOpen.
  TextColumn get memoryId =>
      text().references(MemoryObjects, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get triggerTime => dateTime()();
  TextColumn get timezone => text()();
  IntColumn get status => integer()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get daysBefore => integer()();

  /// Stable platform notification id, so a reminder can still be
  /// cancelled after an app restart.
  IntColumn get notificationId => integer()();

  /// Set only when the user taps the notification — the sole delivery
  /// signal the platform provides. There is deliberately no
  /// `deliveredAt`: nothing could set it truthfully. See
  /// domain/entities/reminder.dart.
  DateTimeColumn get acknowledgedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [MemoryObjects, Reminders])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.connection);

  /// Opens the real, encrypted, on-disk database. Only called from
  /// `presentation/providers/app_providers.dart` — nothing else should
  /// construct an [AppDatabase] directly, so tests can substitute
  /// `AppDatabase(NativeDatabase.memory())` without touching secure storage.
  factory AppDatabase.connect(SecureKeyStore keyStore) {
    return AppDatabase(_openConnection(keyStore));
  }

  /// Still 1 despite the Phase C/D addition of `sourceUri` and `rawText`:
  /// the app has never been released, so no device anywhere holds a v1
  /// database that would need migrating. The first *public* release
  /// freezes this — every schema change after that ships as an explicit
  /// onUpgrade step below plus a migration test (docs/DATABASE.md).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      // SQLite ignores foreign-key constraints unless this is set,
      // per connection — without it `Reminders.memoryId`'s reference
      // to MemoryObjects is documentation, not an enforced constraint,
      // and orphaned reminders could point at deleted memories.
      await customStatement('PRAGMA foreign_keys = ON');
    },
    // Every post-release schema change ships as an explicit onUpgrade
    // step here, with a corresponding migration test — see
    // docs/DATABASE.md and brief section 35.
  );
}

LazyDatabase _openConnection(SecureKeyStore keyStore) {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'keepmind.sqlite'));

    var key = await keyStore.readDatabaseEncryptionKey();
    if (key == null) {
      // First launch: generate a 256-bit key and persist it in
      // Keychain/Keystore before the database is ever created. If this
      // write fails, database creation must not silently proceed with an
      // unencrypted or unrecoverable database — see docs/SECURITY.md.
      key = _generateEncryptionKey();
      await keyStore.writeDatabaseEncryptionKey(key);
    }

    return NativeDatabase.createInBackground(
      dbFile,
      setup: (rawDb) {
        // Requires the SQLite3MultipleCiphers native asset declared in
        // pubspec.yaml's `hooks:` block — without it plain SQLite is
        // bundled, this PRAGMA is silently ignored, and the database is
        // written UNENCRYPTED. See docs/DECISIONS.md ADR-0002 and
        // https://drift.simonbinder.eu/platforms/encryption/.
        rawDb.execute("PRAGMA key = '$key';");
        assert(_debugHasCipher(rawDb));
      },
    );
  });
}

bool _debugHasCipher(Database database) {
  return database.select('PRAGMA cipher;').isNotEmpty;
}

/// Generates a 256-bit key with a cryptographically secure RNG,
/// base64url-encoded so it's a safe `PRAGMA key = '...'` string literal
/// (the base64url alphabet never contains a single quote). Called exactly
/// once per install, on first database open — see [_openConnection].
/// Never logged.
String _generateEncryptionKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return base64Url.encode(bytes);
}
