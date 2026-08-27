import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepmind/data/repositories/memory_repository_impl.dart';
import 'package:keepmind/domain/entitlements/entitlements.dart';
import 'package:keepmind/presentation/providers/app_providers.dart';
import 'package:keepmind/presentation/settings/settings_screen.dart';

import '../support/fake_entitlement_service.dart';
import '../support/fakes.dart';

/// Settings is partly an App Store compliance surface, so these tests pin
/// the things review actually looks for — above all that Restore
/// Purchases is reachable **without** going through the paywall.
Widget _appUnder({FakeEntitlementService? entitlements}) {
  return ProviderScope(
    overrides: [
      memoryRepositoryProvider.overrideWithValue(InMemoryMemoryRepository()),
      ocrServiceProvider.overrideWithValue(FakeOcrService()),
      entitlementServiceProvider.overrideWithValue(
        entitlements ?? FakeEntitlementService(),
      ),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  );
}

void main() {
  testWidgets('offers Restore Purchases without requiring a purchase first', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnder());
    await tester.pumpAndSettle();

    expect(find.text('Restore purchases'), findsOneWidget);
  });

  testWidgets('exposes privacy policy and terms of use', (tester) async {
    await tester.pumpWidget(_appUnder());
    await tester.pumpAndSettle();

    // Both are hard App Store requirements for a subscription app.
    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Terms of use'), findsOneWidget);
  });

  testWidgets('shows the free plan with usage, and an upgrade route', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnder());
    await tester.pumpAndSettle();

    expect(find.text('Free'), findsOneWidget);
    expect(
      find.textContaining('of ${FreeTierLimits.maxActiveMemories} memories'),
      findsOneWidget,
    );
    expect(find.text('Upgrade'), findsOneWidget);
  });

  testWidgets('a subscriber sees Premium and a way to cancel', (tester) async {
    await tester.pumpWidget(
      _appUnder(
        entitlements: FakeEntitlementService(initial: Entitlements.premium),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('Upgrade'), findsNothing);
    // Review expects cancelling to be findable, not buried.
    expect(find.text('Manage subscription'), findsOneWidget);
  });

  testWidgets('restoring reports the outcome plainly', (tester) async {
    final entitlements = FakeEntitlementService();
    await tester.pumpWidget(_appUnder(entitlements: entitlements));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restore purchases'));
    await tester.pumpAndSettle();

    expect(entitlements.restoreCalls, 1);
    // Nothing to restore on a fresh account — say so rather than failing
    // silently or implying something went wrong.
    expect(find.textContaining('No previous purchase found'), findsOneWidget);
  });
}
