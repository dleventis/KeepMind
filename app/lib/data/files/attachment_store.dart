import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/errors/app_errors.dart';

/// Stores captured images inside the app's sandboxed documents directory,
/// one folder per memory.
///
/// Phase C relies on OS-level protection for these files: iOS Data
/// Protection is on by default for app-sandbox files, and Android
/// app-private storage is unreachable by other apps without root. That is
/// deliberately weaker than the database, which is encrypted at rest —
/// per-attachment application-level encryption is Phase I hardening work
/// (see docs/PRIVACY.md), not a Phase C requirement.
///
/// Note that image_picker hands back files in a temporary directory that
/// the OS is free to purge. Anything the user has actually saved must be
/// copied somewhere durable, which is what [persist] is for.
class AttachmentStore {
  const AttachmentStore();

  Future<Directory> _directoryFor(String memoryId) async {
    final documents = await getApplicationDocumentsDirectory();
    return Directory(p.join(documents.path, 'attachments', memoryId));
  }

  /// Copies the file at [sourcePath] into durable storage for [memoryId]
  /// and returns its new absolute path.
  Future<String> persist({
    required String sourcePath,
    required String memoryId,
  }) async {
    try {
      final destination = await _directoryFor(memoryId);
      await destination.create(recursive: true);
      final target = File(p.join(destination.path, p.basename(sourcePath)));
      await File(sourcePath).copy(target.path);
      return target.path;
    } catch (e) {
      throw StorageError(
        debugMessage: 'Failed to persist attachment for $memoryId: $e',
      );
    }
  }

  /// Deletes every attachment belonging to [memoryId]. Called when a
  /// memory is deleted so images don't outlive the record that referenced
  /// them — leaving orphaned copies of someone's passport on disk after
  /// they deleted it would be a real privacy failure, not just untidy.
  Future<void> deleteFor(String memoryId) async {
    try {
      final directory = await _directoryFor(memoryId);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      throw StorageError(
        debugMessage: 'Failed to delete attachments for $memoryId: $e',
      );
    }
  }
}
