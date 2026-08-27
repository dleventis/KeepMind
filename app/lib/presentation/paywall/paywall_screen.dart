import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
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
        title: const Text('Mindkeep Premium'),
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
                    child: _PlanButton(
                      option: option,
                      onPressed: _busy ? null : () => _purchase(option),
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
              if (_options.isNotEmpty) ...[
                const SizedBox(height: 24),
                _SubscriptionTerms(
                  hasFreeTrial: _options.any(
                    (o) => o.introOffer?.isFree ?? false,
                  ),
                  onOpen: _open,
                ),
              ],
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

  Future<void> _open(String url) async {
    // Same reasoning as Settings: no canLaunchUrl() pre-check, because it
    // can return false where launchUrl would have worked, and a dead
    // terms link on a paywall is a rejection.
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Couldn't open $url")));
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

/// One purchasable plan.
///
/// Shows the period, the recurring price, any introductory offer, and —
/// on plans longer than a month — the store's own per-month equivalent,
/// so comparing them is reading rather than arithmetic. Guideline 3.1.2
/// requires the length and price of a subscription to be visible before
/// purchase; a trial that is not stated here would be the app hiding
/// something the user is about to agree to.
class _PlanButton extends StatelessWidget {
  const _PlanButton({required this.option, required this.onPressed});

  final PurchaseOption option;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intro = option.introOffer;
    final perMonth = option.pricePerMonthString;

    return FilledButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              option.displayTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              intro == null
                  ? option.priceLine
                  : '${intro.summary}, then ${option.priceLine}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (perMonth != null) ...[
              const SizedBox(height: 2),
              Text(
                '$perMonth per month',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.75),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The renewal terms and the two links App Store review expects to find
/// on a screen that sells a subscription (Guideline 3.1.2). Kept plain
/// and unstyled — this is information the user is entitled to, not fine
/// print to be survived.
class _SubscriptionTerms extends StatelessWidget {
  const _SubscriptionTerms({required this.hasFreeTrial, required this.onOpen});

  final bool hasFreeTrial;
  final Future<void> Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(color: theme.colorScheme.outlineVariant),
        const SizedBox(height: 12),
        Text(
          'Payment is charged to your Apple ID when you confirm. A '
          'subscription renews automatically unless you cancel it at least '
          '24 hours before the current period ends, and renewal is charged '
          'within 24 hours of that. You can cancel at any time in your '
          'Apple ID settings.',
          style: style,
        ),
        if (hasFreeTrial) ...[
          const SizedBox(height: 8),
          Text(
            'A free trial becomes a paid subscription when it ends, unless '
            'you cancel before then.',
            style: style,
          ),
        ],
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => onOpen(AppConstants.termsOfUseUrl),
              child: const Text('Terms of Use'),
            ),
            Text('·', style: style),
            TextButton(
              onPressed: () => onOpen(AppConstants.privacyPolicyUrl),
              child: const Text('Privacy Policy'),
            ),
          ],
        ),
      ],
    );
  }
}
