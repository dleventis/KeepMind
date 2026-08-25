import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepmind/data/local/database/app_database.dart';
import 'package:keepmind/data/repositories/memory_repository_drift_impl.dart';
import 'package:keepmind/domain/entities/memory_object.dart';

/// Repository tests run against a real in-memory Drift database (no mocks,
/// no platform channels, no disk) — this is the pattern brief section 35
/// asks for: exercising real query/mapping logic without needing a live
/// device or a real encrypted file.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  MemoryObject sample({
    String id = 'mem-1',
    String title = 'Car insurance',
    DateTime? eventDate,
  }) {
    final now = DateTime(2026, 1, 1);
    return MemoryObject(
      id: id,
      title: title,
      category: 'Document',
      sourceType: 'text',
      createdAt: now,
      updatedAt: now,
      eventDate: eventDate,
      confirmationStatus: ConfirmationStatus.confirmed,
      structuredData: const {'provider': 'Example Insurance'},
    );
  }

  test(
    'save then getById round-trips all fields, including structuredData',
    () async {
      final repo = DriftMemoryRepository(db);
      final memory = sample(eventDate: DateTime(2026, 11, 17));

      await repo.save(memory);
      final loaded = await repo.getById(memory.id);

      expect(loaded, isNotNull);
      expect(loaded!.title, 'Car insurance');
      expect(loaded.eventDate, DateTime(2026, 11, 17));
      expect(loaded.structuredData['provider'], 'Example Insurance');
      expect(loaded.confirmationStatus, ConfirmationStatus.confirmed);
    },
  );

  test('getById returns null for an unknown id', () async {
    final repo = DriftMemoryRepository(db);
    expect(await repo.getById('does-not-exist'), isNull);
  });

  test('save with the same id updates rather than duplicates', () async {
    final repo = DriftMemoryRepository(db);
    await repo.save(sample(title: 'Original title'));
    await repo.save(sample(title: 'Updated title'));

    final all = await repo.watchAll().first;
    expect(all, hasLength(1));
    expect(all.single.title, 'Updated title');
  });

  test('delete removes the memory', () async {
    final repo = DriftMemoryRepository(db);
    await repo.save(sample());
    await repo.delete('mem-1');

    expect(await repo.getById('mem-1'), isNull);
  });

  test('watchAll orders soonest event date first, nulls last', () async {
    final repo = DriftMemoryRepository(db);
    await repo.save(sample(id: 'no-date', title: 'No date'));
    await repo.save(
      sample(id: 'later', title: 'Later', eventDate: DateTime(2027, 1, 1)),
    );
    await repo.save(
      sample(id: 'sooner', title: 'Sooner', eventDate: DateTime(2026, 6, 1)),
    );

    final all = await repo.watchAll().first;
    expect(all.map((m) => m.id).toList(), ['sooner', 'later', 'no-date']);
  });
}
