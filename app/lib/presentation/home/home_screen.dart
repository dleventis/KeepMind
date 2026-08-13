import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../capture/capture_screen.dart';
import '../providers/app_providers.dart';

/// The first milestone UI, verbatim from brief section 55:
///
///   KeepMind
///   Nothing you need to remember right now.
///   [ + Remember something ]
///
/// Deliberately not showing counts of overdue items or anxiety-inducing
/// copy — brief section 26: "Everything is under control," not "here are
/// 47 tasks you're failing to complete."
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                memoriesAsync.when(
                  data: (memories) => Text(
                    memories.isEmpty
                        ? AppConstants.emptyHomeMessage
                        : '${memories.length} memories',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text(
                    "Couldn't load your memories right now.",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => _openCapture(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(AppConstants.captureButtonLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCapture(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CaptureScreen()),
    );
  }
}
