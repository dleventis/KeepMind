import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_errors.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/entities/memory_object.dart';
import '../../domain/services/date_candidate_finder.dart';
import '../../data/services/reminder_scheduler.dart';
import '../../domain/services/reminder_planner.dart';
import '../providers/app_providers.dart';
import 'capture_draft.dart';

/// The CONFIRM stage of the product loop. Everything the app worked out
/// is shown as an editable suggestion, never as a fait accompli — the
/// brief is emphatic that only human-confirmed information is trusted for
/// reminders (§6, §16, §29).
///
/// Handles both the OCR path (draft has an image and raw text) and the
/// typed path (empty draft). One screen rather than two because the
/// fields are identical; only the pre-filled suggestions differ.
///
/// The title is deliberately NOT auto-filled from OCR text: the first
/// line of a document is as often a letterhead or logo caption as a
/// useful title, and a wrong pre-filled title is worse than an empty one
/// because people accept defaults without reading them. Title suggestion
/// belongs to the AI extraction stage (Phase F), where it arrives with a
/// confidence score. Dates are different — they are offered as tappable
/// suggestions but never pre-selected, so nothing is ever assumed.
class ConfirmScreen extends ConsumerStatefulWidget {
  const ConfirmScreen({required this.draft, super.key});

  final CaptureDraft draft;

  @override
  ConsumerState<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  static const _categories = [
    'Document',
    'Subscription',
    'Appointment',
    'Physical memory',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = _categories.first;
  DateTime? _eventDate;
  bool _saving = false;
  bool _showRawText = false;

  /// Which "N days before" reminders the user wants. Seeded with the
  /// brief's defaults (§6) so the common case is zero taps, but every one
  /// is toggleable — the app should never quietly decide how often to
  /// interrupt someone.
  final Set<int> _daysBefore = {...ReminderPlanner.defaultDaysBefore};

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;

    return Scaffold(
      appBar: AppBar(
        title: Text(draft.isFromImage ? 'Does this look right?' : 'New memory'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (draft.imagePath != null) ...[
                  _ImagePreview(path: draft.imagePath!),
                  const SizedBox(height: 24),
                ],
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'What is it?',
                    hintText: 'e.g. Car insurance, Spare key location',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Give it a short title.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Details (optional)',
                    hintText: 'Anything else worth remembering',
                  ),
                  minLines: 2,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 24),
                _EventDatePicker(
                  value: _eventDate,
                  onChanged: (date) => setState(() => _eventDate = date),
                ),
                // Gated on having OCR text rather than on having an image:
                // what makes suggestions meaningful is that something was
                // read, and "no dates found" is only worth saying when the
                // app actually looked.
                if (draft.rawText != null) ...[
                  const SizedBox(height: 16),
                  _DateSuggestions(
                    candidates: draft.dateCandidates,
                    selected: _eventDate,
                    onSelect: (date) => setState(() => _eventDate = date),
                  ),
                ],
                // Reminder options only appear once there's a date to
                // hang them off — offering "30 days before" with no date
                // would be meaningless.
                if (_eventDate != null) ...[
                  const SizedBox(height: 24),
                  _ReminderOptions(
                    selected: _daysBefore,
                    eventDate: _eventDate!,
                    onToggle: (days) => setState(() {
                      if (!_daysBefore.remove(days)) _daysBefore.add(days);
                    }),
                  ),
                ],
                if (draft.rawText != null &&
                    draft.rawText!.trim().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _RawTextSection(
                    rawText: draft.rawText!,
                    expanded: _showRawText,
                    onToggle: () =>
                        setState(() => _showRawText = !_showRawText),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save memory'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final id = IdGenerator.generate();
    final now = DateTime.now();
    final draft = widget.draft;

    try {
      // Only copy the image into durable storage once the user has
      // actually committed to saving — image_picker's temp files are
      // disposable, and so is an abandoned capture.
      String? storedPath;
      if (draft.imagePath != null) {
        storedPath = await ref
            .read(attachmentStoreProvider)
            .persist(sourcePath: draft.imagePath!, memoryId: id);
      }

      final memory = MemoryObject(
        id: id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _category,
        sourceType: draft.isFromImage ? 'photo' : 'text',
        createdAt: now,
        updatedAt: now,
        eventDate: _eventDate,
        // Everything on this screen was either typed or explicitly tapped
        // by the user, so it is confirmed by definition. Once AI
        // extraction lands (Phase F), anything the model proposed but the
        // user did not look at stays `pending` instead.
        confirmationStatus: ConfirmationStatus.confirmed,
        sourceUri: storedPath,
        rawText: draft.rawText,
      );

      await ref.read(memoryRepositoryProvider).save(memory);

      // Reminders are scheduled after the memory is safely stored: if
      // scheduling fails, the user still has their memory, which is the
      // more important of the two.
      String? reminderNotice;
      if (memory.eventDate != null && _daysBefore.isNotEmpty) {
        final result = await ref
            .read(reminderSchedulerProvider)
            .scheduleFor(memory, daysBefore: _daysBefore);
        reminderNotice = _reminderNotice(result);
      }

      if (mounted) {
        // Back to Home, clearing the whole capture flow off the stack.
        Navigator.of(context).popUntil((route) => route.isFirst);
        if (reminderNotice != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(reminderNotice)));
        }
      }
    } on AppError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.userMessage)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// Tells the user what will actually happen, rather than implying every
/// requested reminder was set. Silence would be a small lie in the two
/// cases that matter: permission refused, and offsets already in the past.
String? _reminderNotice(SchedulingResult result) {
  if (!result.permissionGranted) {
    return 'Saved. Turn on notifications in Settings and Mindkeep can remind you.';
  }
  if (result.scheduled.isEmpty) {
    return 'Saved. That date is too soon for the reminders you picked.';
  }
  if (result.skippedInPast.isNotEmpty) {
    final count = result.scheduled.length;
    return 'Saved. $count reminder${count == 1 ? '' : 's'} set — the others '
        'would have been in the past.';
  }
  return null;
}

/// Which "N days before" reminders to set.
///
/// Shows the actual calendar date each one lands on rather than just
/// "30 days before", so the user can see at a glance that one of them is
/// next week and another is in October.
class _ReminderOptions extends StatelessWidget {
  const _ReminderOptions({
    required this.selected,
    required this.eventDate,
    required this.onToggle,
  });

  final Set<int> selected;
  final DateTime eventDate;
  final ValueChanged<int> onToggle;

  static const _offsets = [30, 7, 1];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Remind me', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        ..._offsets.map((days) {
          final on = selected.contains(days);
          // Must mirror ReminderPlanner exactly: calendar arithmetic at
          // the planner's hour, NOT `subtract(Duration(days: days))`.
          // Duration subtraction is absolute, so across a DST boundary it
          // lands a day earlier than the planner does — the checkbox
          // would show one date and the notification fire on another.
          // The hour matters too: comparing a midnight value against
          // `now` mislabels the reminder "already passed" for the nine
          // hours before it is actually due.
          final when = DateTime(
            eventDate.year,
            eventDate.month,
            eventDate.day - days,
            ReminderPlanner.defaultHour,
          );
          final past = !when.isAfter(DateTime.now());
          return CheckboxListTile(
            value: on,
            onChanged: (_) => onToggle(days),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(days == 1 ? '1 day before' : '$days days before'),
            subtitle: Text(
              past
                  ? 'Already passed — this one will not be set'
                  : '${when.day.toString().padLeft(2, '0')}/${when.month.toString().padLeft(2, '0')}/${when.year}',
              style: past
                  ? TextStyle(color: Theme.of(context).colorScheme.outline)
                  : null,
            ),
          );
        }),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(path),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          height: 180,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const Text("Couldn't show this image"),
        ),
      ),
    );
  }
}

/// Tappable date suggestions found in the document.
///
/// Ambiguous readings (`03/04/2026` → 3 April or 4 March) are shown as
/// separate chips labelled with how each was read, rather than the app
/// silently choosing one. That is the "I found two possible dates, you
/// pick" behaviour the brief asks for (§16).
class _DateSuggestions extends StatelessWidget {
  const _DateSuggestions({
    required this.candidates,
    required this.selected,
    required this.onSelect,
  });

  final List<DateCandidate> candidates;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No dates found in this document. Set one above if it needs a reminder.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      );
    }

    final hasAmbiguous = candidates.any((c) => c.ambiguous);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasAmbiguous
              ? 'Dates found — some could be read two ways, so pick the right one:'
              : 'Dates found in this document:',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: candidates.map((candidate) {
            return ChoiceChip(
              selected: selected == candidate.date,
              onSelected: (_) => onSelect(candidate.date),
              label: Text(
                candidate.ambiguous
                    ? '${_format(candidate.date)}  (${candidate.interpretation})'
                    : _format(candidate.date),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _format(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

/// The verbatim OCR output, collapsed by default.
///
/// Worth showing at all because it lets the user see *why* the app
/// suggested what it did, and spot a misread before saving. Collapsed by
/// default because a wall of raw OCR text is the opposite of the calm,
/// low-effort UI this product is supposed to have.
class _RawTextSection extends StatelessWidget {
  const _RawTextSection({
    required this.rawText,
    required this.expanded,
    required this.onToggle,
  });

  final String rawText;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(expanded ? Icons.expand_less : Icons.expand_more),
                const SizedBox(width: 8),
                Text(
                  'What the app read',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              rawText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _EventDatePicker extends StatelessWidget {
  const _EventDatePicker({required this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(DateTime.now().year - 5),
          lastDate: DateTime(DateTime.now().year + 20),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Important date (optional)',
          suffixIcon: value == null
              ? const Icon(Icons.calendar_today_outlined)
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onChanged(null),
                ),
        ),
        child: Text(
          value == null
              ? 'No date set'
              : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}',
        ),
      ),
    );
  }
}
