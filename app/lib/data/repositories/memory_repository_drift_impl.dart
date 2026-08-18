import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/errors/app_errors.dart';
import '../../domain/entities/memory_object.dart';
import '../../domain/repositories/memory_repository.dart';
import '../local/database/app_database.dart';

/// The real, persisted implementation of [MemoryRepository], backed by the
/// encrypted Drift database. Swapped in for `InMemoryMemoryRepository` as
/// of Phase B — see `presentation/providers/app_providers.dart`. All
/// mapping between the Drift row shape and the domain entity happens here
/// and nowhere else, so `domain/` stays free of persistence concerns.
class DriftMemoryRepository implements MemoryRepository {
  DriftMemoryRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<MemoryObject>> watchAll() {
    final query = _db.select(_db.memoryObjects)
      ..where((t) => t.archived.equals(false))
      ..orderBy([
        (t) => OrderingTerm(
              // Memories with a soonest-first event date surface first;
              // memories with no event date (physical-location notes,
              // etc.) sort after, newest-created first.
              expression: t.eventDate,
              mode: OrderingMode.asc,
              nulls: NullsOrder.last,
            ),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
          (rows) => rows.map(_rowToEntity).toList(growable: false),
        );
  }

  @override
  Future<MemoryObject?> getById(String id) async {
    final row = await (_db.select(_db.memoryObjects)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _rowToEntity(row);
  }

  @override
  Future<void> save(MemoryObject memory) async {
    try {
      await _db.into(_db.memoryObjects).insertOnConflictUpdate(
            _entityToCompanion(memory),
          );
    } catch (e) {
      throw StorageError(debugMessage: 'Failed to save memory ${memory.id}: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await (_db.delete(_db.memoryObjects)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw StorageError(debugMessage: 'Failed to delete memory $id: $e');
    }
  }

  MemoryObject _rowToEntity(MemoryObjectRow row) {
    return MemoryObject(
      id: row.id,
      title: row.title,
      description: row.description,
      category: row.category,
      sourceType: row.sourceType,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      eventDate: row.eventDate,
      confidenceScore: row.confidenceScore,
      confirmationStatus: ConfirmationStatus.values[row.confirmationStatus],
      sensitivity: Sensitivity.values[row.sensitivity],
      structuredData:
          (jsonDecode(row.structuredData) as Map).cast<String, Object?>(),
      archived: row.archived,
      sourceUri: row.sourceUri,
      rawText: row.rawText,
    );
  }

  MemoryObjectsCompanion _entityToCompanion(MemoryObject memory) {
    return MemoryObjectsCompanion.insert(
      id: memory.id,
      title: memory.title,
      description: Value(memory.description),
      category: memory.category,
      sourceType: memory.sourceType,
      createdAt: memory.createdAt,
      updatedAt: memory.updatedAt,
      eventDate: Value(memory.eventDate),
      confidenceScore: Value(memory.confidenceScore),
      confirmationStatus: memory.confirmationStatus.index,
      sensitivity: Value(memory.sensitivity.index),
      structuredData: Value(jsonEncode(memory.structuredData)),
      archived: Value(memory.archived),
      sourceUri: Value(memory.sourceUri),
      rawText: Value(memory.rawText),
    );
  }
}
