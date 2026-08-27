import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepmind/data/repositories/memory_repository_impl.dart';
import 'package:keepmind/domain/entitlements/entitlement_service.dart';
import 'package:keepmind/presentation/paywall/paywall_screen.dart';
import 'package:keepmind/presentation/providers/app_providers.dart';

import '../support/fake_entitlement_service.dart';
import '../support/fakes.dart';

/// The paywall is the screen App Store review reads most carefully.
/// Guideline 3.1.2 requires the length of the subscription, its price,
/// the renewal terms, and reachable Terms of Use and Privacy Policy links
/// to be visible before the user commits. These tests pin exactly that,
/// so a future layout tidy-up cannot quietly delete a disclosure.
Widget _appUnder({FakeEntitlementService? entitlements}) {
  return ProviderScope(
    overrides: [
      memoryRepositoryProvider.overrideWithValue(InMemoryMemoryRepository()),
      ocrServiceProvider.overrideWithValue(FakeOcrService()),
      entitlementServiceProvider.overrideWithValue(
        entitlements ?? FakeEntitlementService(),
      ),
    ],
    child: const MaterialApp(home: PaywallScreen()),
  );
}

void main() {
  testWidgets('names each plan by its period rather than the store title', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnder());
    await tester.pumpAndSettle();

    // iOS appends the app name to storeProduct.title, so the period
    // label is what the user should actually read.
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
  });

  testWidgets('states the price per period', (tester) async {
    await tester.pumpWidget(_appUnder());
    await tester.pumpAndSettle();

    expect(find.textContaining('1.99 EUR per month'), findsOneWidget);
    expect(find.textContaining('14.99 EUR per year'), findsOneWidget);
  });

  testWidgets('discloses a free trial and what follows it', (tester) async {
    await tester.pumpWidget(_appUnder());
    await tester.pumpAndSettle();

    // Showing only "14.99 EUR per year" while a trial exists would be
    // both a rejection risk and misleading.
    expect(
      find.textContaining('2 weeks free, then 14.99 EUR per year'),
      findsOneWidget,
    );
    expect(
      find.textContaining('becomes a paid subscription when it ends'),
      findsOneWidget,
    );
  });

  testWidgets('shows the per-month equivalent only on longer plans', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnder());
    await tester.pumpAndSettle();

    // Repeating the headline price under the monthly plan would be noise.
    expect(find.text('1.25 EUR per month'), findsOneWidget);
  });

  testWidgets('carries the renewal terms and both required links', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnder());
    await tester.pumpAndSettle();

    expect(find.textContaining('renews automatically'), findsOneWidget);
    expect(find.text('Terms of Use'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Restore'), findsOneWidget);
  });

  testWidgets('says so plainly when the store has nothing to offer', (
    tester,
  ) async {
    final service = FakeEntitlementService()..options = const [];
    await tester.pumpWidget(_appUnder(entitlements: service));
    await tester.pumpAndSettle();

    expect(find.textContaining("store isn't reachable"), findsOneWidget);
    // No terms block without anything to buy — nothing to disclose.
    expect(find.text('Terms of Use'), findsNothing);
  });

  testWidgets('dismissing does not guilt the user', (tester) async {
    await tester.pumpWidget(_appUnder());
    await tester.pumpAndSettle();

    expect(find.text('Not now'), findsOneWidget);
  });
}
