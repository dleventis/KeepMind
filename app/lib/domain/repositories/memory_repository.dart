import '../entities/memory_object.dart';

/// Repository interface — the only thing `presentation/` is allowed to
/// depend on for memory persistence. `data/repositories/memory_repository_impl.dart`
/// provides the concrete implementation; tests can provide an in-memory
/// fake without touching Drift at all.
abstract interface class MemoryRepository {
  Stream<List<MemoryObject>> watchAll();
  Future<MemoryObject?> getById(String id);
  Future<void> save(MemoryObject memory);
  Future<void> delete(String id);
}
