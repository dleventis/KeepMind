import 'package:flutter/material.dart';

/// Placeholder for Phase C (camera/file ingestion). Exists now only so
/// HomeScreen's "+ Remember something" button has somewhere real to go,
/// per the brief's emphasis on the capture flow starting processing
/// immediately (section 27) — that behavior lands in Phase C, not here.
class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remember something')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Camera, photo, document, and text capture land in Phase C.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
