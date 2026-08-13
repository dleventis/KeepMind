import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/id_generator.dart';
import '../../domain/entities/memory_object.dart';
import '../providers/app_providers.dart';

/// Phase B capture: manual typed entry only — the "Typed text" input mode
/// from brief section 5's MVP list, which needs no OCR or AI extraction
/// and so is the one capture path that can ship before Phase D/E/F. Camera,
/// photo, and document capture are visibly present but disabled, with a
/// one-line explanation, rather than silently missing — see the
/// processing-UX principle in brief section 28 about not hiding what
/// isn't ready yet.
///
/// No AI "understand" stage runs here: the user is the source of truth for
/// everything they type, so it goes straight to CONFIRM-equivalent (this
/// form) → STORE, skipping the AI-assisted UNDERSTAND stage entirely.
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remember something')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DisabledCaptureOptionsBanner(),
                const SizedBox(height: 24),
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
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 16),
                _EventDatePicker(
                  value: _eventDate,
                  onChanged: (date) => setState(() => _eventDate = date),
                ),
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

    final now = DateTime.now();
    final memory = MemoryObject(
      id: IdGenerator.generate(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _category,
      sourceType: 'text',
      createdAt: now,
      updatedAt: now,
      eventDate: _eventDate,
      // Typed directly by the user — nothing here was AI-extracted, so it
      // is trusted immediately rather than sitting in `pending` awaiting a
      // confirmation step that doesn't apply to manual entry.
      confirmationStatus: ConfirmationStatus.confirmed,
    );

    try {
      await ref.read(memoryRepositoryProvider).save(memory);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DisabledCaptureOptionsBanner extends StatelessWidget {
  const _DisabledCaptureOptionsBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt_outlined,
                    color: Theme.of(context).disabledColor),
                const SizedBox(width: 12),
                Icon(Icons.photo_outlined,
                    color: Theme.of(context).disabledColor),
                const SizedBox(width: 12),
                Icon(Icons.description_outlined,
                    color: Theme.of(context).disabledColor),
                const Spacer(),
                const Text('Coming soon'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Camera, photo, and document capture with automatic reading '
              'arrive in a later phase. For now, type it in below.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
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
          firstDate: DateTime(DateTime.now().year - 1),
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
              ? 'No date set — this becomes a reminder once set'
              : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }
}
