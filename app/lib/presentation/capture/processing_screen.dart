import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_errors.dart';
import '../../domain/services/date_candidate_finder.dart';
import '../providers/app_providers.dart';
import 'capture_draft.dart';
import 'confirm_screen.dart';

/// Named stages of the capture pipeline. The brief is specific about this
/// (§28): no indefinite spinner, tell the user what is actually
/// happening. These are real steps, not a fake progress animation — each
/// one is set as that work begins.
enum _Stage {
  reading('Reading the image…'),
  findingDates('Looking for important dates…'),
  preparing('Preparing…');

  const _Stage(this.label);
  final String label;
}

/// Runs OCR on a captured image, then hands off to the confirmation
/// screen. Replaces itself in the navigation stack on success, so backing
/// out of confirmation returns to the capture chooser rather than to a
/// processing screen with nothing left to do.
class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({required this.imagePath, super.key});

  final String imagePath;

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  _Stage _stage = _Stage.reading;
  AppError? _error;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      final ocr = ref.read(ocrServiceProvider);
      final rawText = await ocr.extractText(widget.imagePath);
      if (_cancelled || !mounted) return;

      setState(() => _stage = _Stage.findingDates);
      // Deterministic, local, no AI — see DateCandidateFinder's docs.
      final candidates = DateCandidateFinder.find(rawText);
      if (_cancelled || !mounted) return;

      setState(() => _stage = _Stage.preparing);
      final draft = CaptureDraft(
        imagePath: widget.imagePath,
        rawText: rawText,
        dateCandidates: candidates,
      );

      if (_cancelled || !mounted) return;
      // pushReplacement: processing is a transient step, not somewhere
      // the user should be able to navigate back into.
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ConfirmScreen(draft: draft)),
      );
    } on AppError catch (e) {
      if (mounted) setState(() => _error = e);
    } catch (e) {
      if (mounted) {
        setState(() => _error = OCRFailure(debugMessage: 'Unexpected: $e'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;

    return Scaffold(
      appBar: AppBar(title: const Text('Reading…')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: error != null
                ? _ErrorView(
                    error: error,
                    onRetry: () {
                      setState(() {
                        _error = null;
                        _stage = _Stage.reading;
                      });
                      _run();
                    },
                    onEnterManually: () =>
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ConfirmScreen(
                              draft: CaptureDraft(imagePath: widget.imagePath),
                            ),
                          ),
                        ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 32),
                      Text(
                        _stage.label,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          _cancelled = true;
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.onEnterManually,
  });

  final AppError error;
  final VoidCallback onRetry;
  final VoidCallback onEnterManually;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          error.userMessage,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton(onPressed: onRetry, child: const Text('Try again')),
        const SizedBox(height: 8),
        // OCR failing must never be a dead end — the user still has a
        // photo and can always describe it themselves.
        TextButton(
          onPressed: onEnterManually,
          child: const Text('Enter the details myself'),
        ),
      ],
    );
  }
}
