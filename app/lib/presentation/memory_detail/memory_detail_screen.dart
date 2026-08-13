import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/memory_object.dart';
import '../providers/app_providers.dart';

/// View, edit, and delete a single confirmed memory. Editing is inline on
/// this screen rather than a separate route — Phase B scope doesn't
/// justify two screens for what's currently a handful of plain-text
/// fields; revisit once structured, category-specific fields (Phase F)
/// make a dedicated edit flow worth it.
class MemoryDetailScreen extends ConsumerStatefulWidget {
  const MemoryDetailScreen({required this.memoryId, super.key});

  final String memoryId;

  @override
  ConsumerState<MemoryDetailScreen> createState() =>
      _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends ConsumerState<MemoryDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  MemoryObject? _loaded;
  DateTime? _eventDate;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _hydrate(MemoryObject memory) {
    if (_loaded != null) return; // only hydrate controllers once
    _loaded = memory;
    _titleController.text = memory.title;
    _descriptionController.text = memory.description ?? '';
    _eventDate = memory.eventDate;
  }

  @override
  Widget build(BuildContext context) {
    final memoryAsync = ref.watch(memoriesStreamProvider).whenData(
          (memories) => memories.where((m) => m.id == widget.memoryId).firstOrNull,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _loaded == null ? null : _confirmDelete,
          ),
        ],
      ),
      body: memoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text("Couldn't load this memory.")),
        data: (memory) {
          if (memory == null) {
            // Deleted from elsewhere, or bad id.
            return const Center(child: Text('This memory no longer exists.'));
          }
          _hydrate(memory);
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  Text('Category: ${memory.category}',
                      style: Theme.of(context).textTheme.bodyMedium),
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
    final updated = current.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      clearDescription: _descriptionController.text.trim().isEmpty,
      updatedAt: DateTime.now(),
    );
    try {
      await ref.read(memoryRepositoryProvider).save(updated);
      if (mounted) setState(() => _dirty = false);
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
    if (confirmed == true) {
      await ref.read(memoryRepositoryProvider).delete(widget.memoryId);
      if (mounted) Navigator.of(context).pop();
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
