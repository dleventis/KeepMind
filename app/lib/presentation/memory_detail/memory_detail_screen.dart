import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_errors.dart';
import '../../domain/entities/memory_object.dart';
import '../providers/app_providers.dart';

/// View, edit, and delete a single memory. Editing is inline rather than
/// a separate route — Phase B/C scope doesn't justify two screens for a
/// handful of plain fields; revisit once structured, category-specific
/// fields (Phase F) make a dedicated edit flow worth it.
class MemoryDetailScreen extends ConsumerStatefulWidget {
  const MemoryDetailScreen({required this.memoryId, super.key});

  final String memoryId;

  @override
  ConsumerState<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends ConsumerState<MemoryDetailScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _hydrated = false;
  DateTime? _eventDate;
  bool _dirty = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Seeds the controllers once. Re-hydrating on every rebuild would
  /// stomp on whatever the user is currently typing each time the
  /// underlying stream emits.
  void _hydrate(MemoryObject memory) {
    if (_hydrated) return;
    _hydrated = true;
    _titleController.text = memory.title;
    _descriptionController.text = memory.description ?? '';
    _eventDate = memory.eventDate;
  }

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(memoriesStreamProvider);
    // `.value` — Riverpod 3.x has no `valueOrNull`; `value` is already
    // nullable (null while loading or on error).
    final matches = memoriesAsync.value
            ?.where((m) => m.id == widget.memoryId)
            .toList() ??
        const <MemoryObject>[];
    final memory = matches.isEmpty ? null : matches.first;

    if (memory != null) _hydrate(memory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            // Driven off the streamed value, not a field set during the
            // body build — named arguments evaluate in source order, so
            // an `appBar:` reading state written by `body:` would always
            // see the previous frame's value and stay disabled.
            onPressed: memory == null ? null : _confirmDelete,
          ),
        ],
      ),
      body: memoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text("Couldn't load this memory.")),
        data: (_) {
          if (memory == null) {
            return const Center(child: Text('This memory no longer exists.'));
          }
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (memory.sourceUri != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(memory.sourceUri!),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          height: 180,
                          alignment: Alignment.center,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Text('Image unavailable'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    onChanged: (_) => setState(() => _dirty = true),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Details'),
                    minLines: 2,
                    maxLines: 5,
                    onChanged: (_) => setState(() => _dirty = true),
                  ),
                  const SizedBox(height: 16),
                  _DateField(
                    value: _eventDate,
                    onChanged: (date) => setState(() {
                      _eventDate = date;
                      _dirty = true;
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category: ${memory.category}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  if (_dirty)
                    FilledButton(
                      onPressed: _saving ? null : () => _save(memory),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save changes'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _save(MemoryObject current) async {
    setState(() => _saving = true);
    final description = _descriptionController.text.trim();
    final updated = current.copyWith(
      title: _titleController.text.trim(),
      description: description,
      clearDescription: description.isEmpty,
      // Without these two the date silently reverted to whatever was
      // stored, so clearing or changing a date in the UI did nothing.
      eventDate: _eventDate,
      clearEventDate: _eventDate == null,
      updatedAt: DateTime.now(),
    );
    try {
      await ref.read(memoryRepositoryProvider).save(updated);
      if (mounted) setState(() => _dirty = false);
    } on AppError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.userMessage)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this memory?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // The repository also removes any stored image for this memory.
    await ref.read(memoryRepositoryProvider).delete(widget.memoryId);
    if (mounted) Navigator.of(context).pop();
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onChanged});

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
          labelText: 'Important date',
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
