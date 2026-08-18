import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/errors/app_errors.dart';
import 'capture_draft.dart';
import 'confirm_screen.dart';
import 'processing_screen.dart';

/// Pick how to capture. The brief wants this to take 5–10 seconds end to
/// end (§4), so this screen is three large targets and nothing else — no
/// tabs, no nested menus, no configuration before the user has given the
/// app anything.
///
/// Camera capture goes through image_picker rather than the `camera`
/// package: image_picker hands off to the OS camera UI, which means no
/// preview/controller lifecycle to manage, no orientation handling, and a
/// far smaller permissions and App Store review surface. A custom
/// in-app camera with edge detection would be nicer eventually, but it is
/// not what makes this product work. See ADR-0005 in docs/DECISIONS.md.
class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remember something')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CaptureOption(
              icon: Icons.camera_alt_outlined,
              title: 'Take a photo',
              subtitle: 'Photograph a document, letter, or label',
              onTap: () => _pickImage(context, ImageSource.camera),
            ),
            const SizedBox(height: 12),
            _CaptureOption(
              icon: Icons.photo_library_outlined,
              title: 'Choose a photo or screenshot',
              subtitle: 'Pick something already on your phone',
              onTap: () => _pickImage(context, ImageSource.gallery),
            ),
            const SizedBox(height: 12),
            _CaptureOption(
              icon: Icons.edit_outlined,
              title: 'Type it in',
              subtitle: 'Write it down yourself',
              onTap: () => _openConfirm(context, const CaptureDraft()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        // Full-resolution photos are large and slow to OCR without being
        // meaningfully more accurate for printed text. This is a starting
        // point, worth revisiting against real accuracy data.
        imageQuality: 85,
        maxWidth: 2000,
      );
      // Null means the user backed out of the camera/picker — not an
      // error, just nothing to do.
      if (picked == null || !context.mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProcessingScreen(imagePath: picked.path),
        ),
      );
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      // image_picker surfaces a denied camera/photos permission as a
      // PlatformException rather than a typed error.
      final error = e.code == 'camera_access_denied' ||
              e.code == 'photo_access_denied'
          ? const PermissionError(permission: 'camera or photo library')
          : const StorageError(debugMessage: 'image_picker failed');
      _showError(context, error);
    }
  }

  Future<void> _openConfirm(BuildContext context, CaptureDraft draft) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ConfirmScreen(draft: draft)),
    );
  }

  void _showError(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.userMessage)),
    );
  }
}

class _CaptureOption extends StatelessWidget {
  const _CaptureOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
