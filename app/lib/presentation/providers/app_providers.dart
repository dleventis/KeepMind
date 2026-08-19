import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/files/attachment_store.dart';
import '../../data/local/database/app_database.dart';
import '../../data/local/secure/secure_key_store.dart';
import '../../data/ocr/mlkit_ocr_service.dart';
import '../../data/repositories/memory_repository_drift_impl.dart';
import '../../domain/entities/memory_object.dart';
import '../../domain/repositories/memory_repository.dart';
import '../../domain/services/ocr_service.dart';

/// Central provider wiring. This is the one file allowed to import both a
/// repository/service interface and its concrete implementation, and both
/// a domain entity and a persistence type (see docs/ARCHITECTURE.md).
///
/// Widget tests override these with fakes rather than touching real
/// platform channels — see `test/widget/home_screen_test.dart`.
final secureKeyStoreProvider = Provider<SecureKeyStore>((ref) {
  return SecureKeyStore();
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.connect(ref.watch(secureKeyStoreProvider));
  ref.onDispose(db.close);
  return db;
});

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return DriftMemoryRepository(
    ref.watch(appDatabaseProvider),
    attachments: ref.watch(attachmentStoreProvider),
  );
});

final memoriesStreamProvider = StreamProvider<List<MemoryObject>>((ref) {
  return ref.watch(memoryRepositoryProvider).watchAll();
});

/// On-device OCR (Phase D). Disposed explicitly because ML Kit holds
/// native recognizer memory that Dart's GC will not reclaim.
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = MlKitOcrService();
  ref.onDispose(service.dispose);
  return service;
});

final attachmentStoreProvider = Provider<AttachmentStore>((ref) {
  return const AttachmentStore();
});
