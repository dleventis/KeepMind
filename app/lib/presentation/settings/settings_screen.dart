import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entitlements/entitlements.dart';
import '../paywall/paywall_screen.dart';
import '../providers/app_providers.dart';

/// Settings.
///
/// Partly a product screen and partly an App Store compliance surface.
/// Review expects an app selling a subscription to offer, reachable
/// without buying anything: **Restore Purchases**, a link to manage or
/// cancel the subscription, a privacy policy, and terms of use. An app
/// that only exposes Restore from inside its paywall tends to get
/// rejected — which is exactly why this screen exists now rather than
/// in a later polish pass.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _restoring = false;

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(entitlementsProvider).value?.isPremium ?? false;
    final count = ref.watch(activeMemoryCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          children: [
            _SectionHeader('Your plan'),
            ListTile(
              title: Text(isPremium ? 'Premium' : 'Free'),
              subtitle: Text(
                isPremium
                    ? 'Unlimited memories'
                    : '$count of ${FreeTierLimits.maxActiveMemories} memories used',
              ),
              trailing: isPremium
                  ? const Icon(Icons.check_circle_outline)
                  : FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PaywallScreen(),
                        ),
                      ),
                      child: const Text('Upgrade'),
                    ),
            ),
            ListTile(
              title: const Text('Restore purchases'),
              subtitle: const Text(
                'If you already subscribed, on this or another device',
              ),
              trailing: _restoring
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              onTap: _restoring ? null : _restore,
            ),
            if (isPremium)
              ListTile(
                title: const Text('Manage subscription'),
                subtitle: const Text('Change or cancel in the App Store'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _open(AppConstants.manageSubscriptionsUrl),
              ),

            const Divider(height: 32),
            _SectionHeader('Your data'),
            const ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Everything stays on this device'),
              subtitle: Text(
                'Your memories and documents are stored in an encrypted '
                'database on your phone. Documents are read on-device, and '
                'nothing is uploaded.',
              ),
            ),

            const Divider(height: 32),
            _SectionHeader('About'),
            ListTile(
              title: const Text('Privacy policy'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _open(AppConstants.privacyPolicyUrl),
            ),
            ListTile(
              title: const Text('Terms of use'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _open(AppConstants.termsOfUseUrl),
            ),
            const ListTile(
              title: Text(AppConstants.appName),
              subtitle: Text(AppConstants.tagline),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    final restored = await ref.read(entitlementServiceProvider).restore();
    if (!mounted) return;
    setState(() => _restoring = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          restored.isPremium
              ? 'Premium restored.'
              : 'No previous purchase found for this Apple ID.',
        ),
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    // Deliberately no canLaunchUrl() pre-check: its own docs note it can
    // return false even where launchUrl would have worked, and a false
    // negative here would leave the user staring at a dead privacy-policy
    // link. Try, and report honestly if it fails.
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Couldn't open $url")));
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
