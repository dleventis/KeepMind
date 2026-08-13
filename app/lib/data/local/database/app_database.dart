import 'dart:io';

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

  /// JSON-encoded Map<String, Object?> — category-specific fields.
  TextColumn get structuredData => text().withDefault(const Constant('{}'))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Phase G will add this table when the reminder scheduler is built —
/// declared here now so the schema-versioning story starts from a
/// realistic shape. See docs/REMINDERS.md.
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get memoryId => text().references(MemoryObjects, #id)();
  DateTimeColumn get triggerTime => dateTime()();
  TextColumn get timezone => text()();
  IntColumn get status => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deliveredAt => dateTime().nullable()();
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

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        // Every future schema change ships as an explicit onUpgrade step
        // here, with a corresponding migration test — see
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
        // See docs/DECISIONS.md ADR-0002 and
        // https://drift.simonbinder.eu/platforms/encryption/ — this
        // requires the SQLite3MultipleCiphers native asset configured in
        // pubspec.yaml, verified locally before Phase B (see comment
        // there; this sandbox couldn't reach pub.dev to confirm the exact
        // current native-assets syntax).
        rawDb.execute("PRAGMA key = '$key';");
        assert(_debugHasCipher(rawDb));
      },
    );
  });
}

bool _debugHasCipher(Database database) {
  return database.select('PRAGMA cipher;').isNotEmpty;
}

String _generateEncryptionKey() {
  // TODO(phase-b): replace with a cryptographically secure RNG
  // (e.g. `Random.secure()` combined with a vetted hex/base64 encoding)
  // before this leaves the skeleton stage — left as an explicit TODO
  // rather than silently shipping a weak key.
  throw UnimplementedError(
    'Encryption key generation is a Phase B task — see docs/SECURITY.md.',
  );
}
