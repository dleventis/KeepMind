import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/memory_object.dart';
import '../../domain/entitlements/entitlements.dart';
import '../capture/capture_screen.dart';
import '../memory_detail/memory_detail_screen.dart';
import '../paywall/paywall_screen.dart';
import '../providers/app_providers.dart';
import '../settings/settings_screen.dart';

/// Home screen. Phase A shipped only the empty state; Phase B adds the
/// actual memory list, still deliberately calm — no counts of overdue
/// items, no red badges (brief section 26: "everything is under control,"
/// not "here are 47 tasks you're failing to complete").
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesStreamProvider);
    final isPremium = ref.watch(entitlementsProvider).value?.isPremium ?? false;
    final count = ref.watch(activeMemoryCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCapture(context, ref),
        icon: const Icon(Icons.add),
        label: const Text(AppConstants.captureButtonLabel),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Only appears in the last couple of slots. A persistent
            // "7 of 10 used" counter would turn a calm screen into a
            // meter the user feels watched by.
            if (FreeTierLimits.shouldWarn(
              currentCount: count,
              isPremium: isPremium,
            ))
              _FreeTierNotice(
                remaining:
                    FreeTierLimits.remainingSlots(
                      currentCount: count,
                      isPremium: isPremium,
                    ) ??
                    0,
                onSeeOptions: () => _openPaywall(context),
              ),
            Expanded(
              child: memoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => const Center(
                  child: Text("Couldn't load your memories right now."),
                ),
                data: (memories) => memories.isEmpty
                    ? _EmptyState(onCapture: () => _openCapture(context, ref))
                    : _MemoryList(memories: memories),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The limit is checked HERE rather than on save, so someone who has
  /// run out is told before they photograph a document and fill in a
  /// form — not after, with their work about to be thrown away.
  Future<void> _openCapture(BuildContext context, WidgetRef ref) async {
    if (!ref.read(canCreateMemoryProvider)) {
      final purchased = await _openPaywall(context);
      if (purchased != true) return;
    }
    if (!context.mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CaptureScreen()));
  }

  Future<bool?> _openPaywall(BuildContext context) {
    return Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const PaywallScreen()));
  }
}

/// A quiet heads-up in the last two free slots, not a nag.
class _FreeTierNotice extends StatelessWidget {
  const _FreeTierNotice({required this.remaining, required this.onSeeOptions});

  final int remaining;
  final VoidCallback onSeeOptions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              remaining == 0
                  ? "You've used all your free memories."
                  : remaining == 1
                  ? '1 free memory left.'
                  : '$remaining free memories left.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          TextButton(onPressed: onSeeOptions, child: const Text('See options')),
        ],
      ),
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
