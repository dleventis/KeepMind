import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/files/attachment_store.dart';
import '../../data/local/database/app_database.dart';
import '../../data/local/secure/secure_key_store.dart';
import '../../data/notifications/local_notification_service.dart';
import '../../data/ocr/mlkit_ocr_service.dart';
import '../../data/purchases/revenuecat_entitlement_service.dart';
import '../../data/repositories/memory_repository_drift_impl.dart';
import '../../data/repositories/reminder_repository_drift_impl.dart';
import '../../data/services/reminder_scheduler.dart';
import '../../domain/entitlements/entitlement_service.dart';
import '../../domain/entitlements/entitlements.dart';
import '../../domain/entities/memory_object.dart';
import '../../domain/repositories/memory_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/services/notification_service.dart';
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

// --- Reminders (Phase G) -------------------------------------------------

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationService();
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return DriftReminderRepository(ref.watch(appDatabaseProvider));
});

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return ReminderScheduler(
    reminders: ref.watch(reminderRepositoryProvider),
    notifications: ref.watch(notificationServiceProvider),
  );
});

// --- Entitlements / monetization (Phase K) -------------------------------

final entitlementServiceProvider = Provider<EntitlementService>((ref) {
  final service = RevenueCatEntitlementService();
  ref.onDispose(service.dispose);
  return service;
});

/// Current entitlements, defaulting to free until the store answers.
/// Pessimistic by design: a network failure must never hand out premium,
/// and because the free tier is fully usable, being briefly wrong costs
/// the user nothing.
final entitlementsProvider = StreamProvider<Entitlements>((ref) {
  return ref.watch(entitlementServiceProvider).watch();
});

/// How many memories count against the free limit — the same set the
/// Home list shows, so the number the user sees and the number enforced
/// can never disagree.
final activeMemoryCountProvider = Provider<int>((ref) {
  return ref.watch(memoriesStreamProvider).value?.length ?? 0;
});

/// Whether another memory may be created right now.
final canCreateMemoryProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(entitlementsProvider).value?.isPremium ?? false;
  return FreeTierLimits.canCreateMemory(
    currentCount: ref.watch(activeMemoryCountProvider),
    isPremium: isPremium,
  );
});
