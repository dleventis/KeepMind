import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database/app_database.dart';
import '../../data/local/secure/secure_key_store.dart';
import '../../data/repositories/memory_repository_drift_impl.dart';
import '../../domain/entities/memory_object.dart';
import '../../domain/repositories/memory_repository.dart';

/// Central provider wiring. This is the one file allowed to import both a
/// repository interface and its concrete implementation, and both a
/// domain entity and a persistence type (see docs/ARCHITECTURE.md).
///
/// Phase B note: as of this phase the app is wired to the real,
/// encrypted, on-disk Drift database rather than the Phase A in-memory
/// stub. `data/repositories/memory_repository_impl.dart`
/// (`InMemoryMemoryRepository`) still exists and is what widget tests use
/// via provider overrides — see `test/widget/home_screen_test.dart` — so
/// tests never touch the real database or secure storage.
final secureKeyStoreProvider = Provider<SecureKeyStore>((ref) {
  return SecureKeyStore();
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.connect(ref.watch(secureKeyStoreProvider));
  ref.onDispose(db.close);
  return db;
});

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return DriftMemoryRepository(ref.watch(appDatabaseProvider));
});

final memoriesStreamProvider = StreamProvider<List<MemoryObject>>((ref) {
  return ref.watch(memoryRepositoryProvider).watchAll();
});
