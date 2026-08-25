import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entitlements/entitlement_service.dart';
import '../../domain/entitlements/entitlements.dart';
import '../providers/app_providers.dart';

/// The paywall.
///
/// Written to be honest rather than persuasive: it states the limit, what
/// paying changes, and the store's own price. No countdown, no fake
/// scarcity, no pre-ticked upsell, no guilt copy on the dismiss button —
/// the brief rules out dark patterns (§53), and a memory app asking to be
/// trusted with someone's passport is the last place to start
/// manipulating them.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  List<PurchaseOption> _options = const [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final options = await ref
        .read(entitlementServiceProvider)
        .availableOptions();
    if (mounted) {
      setState(() {
        _options = options;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KeepMind Premium'),
        actions: [
          TextButton(
            onPressed: _busy ? null : _restore,
            child: const Text('Restore'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "You've used all ${FreeTierLimits.maxActiveMemories} free memories",
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Premium removes the limit so you can keep everything that '
                'matters in one place.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              const _Benefit(
                icon: Icons.all_inclusive,
                text: 'Unlimited memories',
              ),
              const _Benefit(
                icon: Icons.camera_alt_outlined,
                text: 'Photo capture and document reading stay included',
              ),
              const _Benefit(
                icon: Icons.notifications_active_outlined,
                text: 'All your reminders, exactly as you set them',
              ),
              const SizedBox(height: 24),
              // Said plainly and up front, because it is the thing people
              // are most anxious about when a limit appears.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_open_outlined,
                      size: 20,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Everything you have already saved stays yours. '
                        'Your existing memories and reminders keep working '
                        'whether or not you subscribe.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_options.isEmpty)
                Text(
                  "The store isn't reachable right now. Please try again "
                  'later — nothing you have saved is affected.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                )
              else
                ..._options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FilledButton(
                      onPressed: _busy ? null : () => _purchase(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text('${option.title} — ${option.priceString}'),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                // Neutral wording. "No thanks, I like forgetting things"
                // is the kind of copy this app will not ship.
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _purchase(PurchaseOption option) async {
    setState(() => _busy = true);
    final outcome = await ref.read(entitlementServiceProvider).purchase(option);
    if (!mounted) return;
    setState(() => _busy = false);

    switch (outcome) {
      case PurchaseOutcome.purchased:
        Navigator.of(context).pop(true);
      case PurchaseOutcome.cancelled:
        // Deliberately silent — the user chose this.
        break;
      case PurchaseOutcome.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("That didn't go through. You have not been charged."),
          ),
        );
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    final restored = await ref.read(entitlementServiceProvider).restore();
    if (!mounted) return;
    setState(() => _busy = false);

    if (restored.isPremium) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous purchase found.')),
      );
    }
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
