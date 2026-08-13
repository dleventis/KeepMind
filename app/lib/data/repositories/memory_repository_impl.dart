import 'dart:async';

import '../../domain/entities/memory_object.dart';
import '../../domain/repositories/memory_repository.dart';

/// Phase A placeholder implementation: an in-memory store so the app is
/// runnable and testable before the Drift-backed database
/// (`data/local/database/app_database.dart`) has generated code and a real
/// migration in place. Swapping this for a Drift-backed implementation in
/// Phase B is a one-line change in `presentation/providers/app_providers.dart`
/// — nothing above this class needs to change.
class InMemoryMemoryRepository implements MemoryRepository {
  final _memories = <String, MemoryObject>{};
  final _controller = StreamController<List<MemoryObject>>.broadcast();

  void _emit() => _controller.add(_memories.values.toList(growable: false));

  @override
  Stream<List<MemoryObject>> watchAll() async* {
    yield _memories.values.toList(growable: false);
    yield* _controller.stream;
  }

  @override
  Future<MemoryObject?> getById(String id) async => _memories[id];

  @override
  Future<void> save(MemoryObject memory) async {
    _memories[memory.id] = memory;
    _emit();
  }

  @override
  Future<void> delete(String id) async {
    _memories.remove(id);
    _emit();
  }
}
