import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/memory_object.dart';
import '../capture/capture_screen.dart';
import '../memory_detail/memory_detail_screen.dart';
import '../providers/app_providers.dart';

/// Home screen. Phase A shipped only the empty state; Phase B adds the
/// actual memory list, still deliberately calm — no counts of overdue
/// items, no red badges (brief section 26: "everything is under control,"
/// not "here are 47 tasks you're failing to complete").
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCapture(context),
        icon: const Icon(Icons.add),
        label: const Text(AppConstants.captureButtonLabel),
      ),
      body: SafeArea(
        child: memoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const Center(
            child: Text("Couldn't load your memories right now."),
          ),
          data: (memories) => memories.isEmpty
              ? _EmptyState(onCapture: () => _openCapture(context))
              : _MemoryList(memories: memories),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCapture});

  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConstants.emptyHomeMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onCapture,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(AppConstants.captureButtonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryList extends StatelessWidget {
  const _MemoryList({required this.memories});

  final List<MemoryObject> memories;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: memories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final memory = memories[index];
        return Card(
          child: ListTile(
            title: Text(memory.title),
            subtitle: Text(_subtitle(memory)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MemoryDetailScreen(memoryId: memory.id),
              ),
            ),
          ),
        );
      },
    );
  }

  String _subtitle(MemoryObject memory) {
    final parts = <String>[memory.category];
    final eventDate = memory.eventDate;
    if (eventDate != null) {
      parts.add(
        '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}',
      );
    }
    return parts.join(' · ');
  }
}
