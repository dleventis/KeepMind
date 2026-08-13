import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/memory_repository_impl.dart';
import '../../domain/entities/memory_object.dart';
import '../../domain/repositories/memory_repository.dart';

/// Central provider wiring. This is the one file allowed to import both a
/// repository interface and its concrete implementation (see
/// docs/ARCHITECTURE.md). Phase A wires the in-memory repository;
/// switching to the Drift-backed one in Phase B is a one-line change here.
final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return InMemoryMemoryRepository();
});

final memoriesStreamProvider = StreamProvider<List<MemoryObject>>((ref) {
  return ref.watch(memoryRepositoryProvider).watchAll();
});
