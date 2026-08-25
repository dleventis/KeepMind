import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepmind/core/constants/app_constants.dart';
import 'package:keepmind/data/repositories/memory_repository_impl.dart';
import 'package:keepmind/domain/entitlements/entitlements.dart';
import 'package:keepmind/domain/entities/memory_object.dart';
import 'package:keepmind/domain/repositories/memory_repository.dart';
import 'package:keepmind/domain/services/date_candidate_finder.dart';
import 'package:keepmind/presentation/capture/capture_draft.dart';
import 'package:keepmind/presentation/capture/confirm_screen.dart';
import 'package:keepmind/presentation/home/home_screen.dart';
import 'package:keepmind/presentation/providers/app_providers.dart';

import '../support/fake_entitlement_service.dart';
import '../support/fakes.dart';

/// Widget tests override the repository and OCR providers with fakes —
/// never the real Drift-backed or ML Kit implementations, which need
/// platform channels (path_provider, flutter_secure_storage, ML Kit)
/// unavailable in a plain widget test. See brief §35.
Widget _appUnder(
  Widget home, {
  MemoryRepository? repository,
  FakeOcrService? ocr,
  FakeEntitlementService? entitlements,
}) {
  return ProviderScope(
    overrides: [
      memoryRepositoryProvider.overrideWithValue(
        repository ?? InMemoryMemoryRepository(),
      ),
      ocrServiceProvider.overrideWithValue(ocr ?? FakeOcrService()),
      // Without this the real RevenueCat service would be constructed and
      // reach for platform channels that do not exist in a widget test.
      entitlementServiceProvider.overrideWithValue(
        entitlements ?? FakeEntitlementService(),
      ),
    ],
    child: MaterialApp(home: home),
  );
}

Future<InMemoryMemoryRepository> _repositoryWith(int count) async {
  final repository = InMemoryMemoryRepository();
  final now = DateTime(2026, 8, 25);
  for (var i = 0; i < count; i++) {
    await repository.save(
      MemoryObject(
        id: 'mem-$i',
        title: 'Memory $i',
        category: 'Document',
        sourceType: 'text',
        createdAt: now,
        updatedAt: now,
        confirmationStatus: ConfirmationStatus.confirmed,
      ),
    );
  }
  return repository;
}

void main() {
  group('free tier limit', () {
    testWidgets('lets a free user under the limit capture normally', (
      tester,
    ) async {
      final repository = await _repositoryWith(3);
      await tester.pumpWidget(
        _appUnder(const HomeScreen(), repository: repository),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppConstants.captureButtonLabel).first);
      await tester.pumpAndSettle();

      expect(find.text('Take a photo'), findsOneWidget);
      expect(find.text('KeepMind Premium'), findsNothing);
    });

    testWidgets('shows the paywall instead of capture once the limit is hit', (
      tester,
    ) async {
      final repository = await _repositoryWith(
        FreeTierLimits.maxActiveMemories,
      );
      await tester.pumpWidget(
        _appUnder(const HomeScreen(), repository: repository),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppConstants.captureButtonLabel).first);
      await tester.pumpAndSettle();

      // Hit BEFORE the capture flow, so nobody photographs a document and
      // fills in a form only to be told it cannot be saved.
      expect(find.text('KeepMind Premium'), findsOneWidget);
      expect(find.text('Take a photo'), findsNothing);
    });

    testWidgets('a premium user is never gated', (tester) async {
      final repository = await _repositoryWith(
        FreeTierLimits.maxActiveMemories + 5,
      );
      await tester.pumpWidget(
        _appUnder(
          const HomeScreen(),
          repository: repository,
          entitlements: FakeEntitlementService(initial: Entitlements.premium),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppConstants.captureButtonLabel).first);
      await tester.pumpAndSettle();

      expect(find.text('Take a photo'), findsOneWidget);
    });

    testWidgets('an over-limit free user can still read what they saved', (
      tester,
    ) async {
      // The case that matters most ethically: a lapsed subscriber must
      // never lose access to their own passport expiry.
      final repository = await _repositoryWith(
        FreeTierLimits.maxActiveMemories + 4,
      );
      await tester.pumpWidget(
        _appUnder(const HomeScreen(), repository: repository),
      );
      await tester.pumpAndSettle();

      expect(find.text('Memory 0'), findsOneWidget);
      expect(
        find.textContaining('used all your free memories'),
        findsOneWidget,
      );
    });

    testWidgets('warns only in the last two slots', (tester) async {
      final repository = await _repositoryWith(5);
      await tester.pumpWidget(
        _appUnder(const HomeScreen(), repository: repository),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('free memories left'), findsNothing);
    });
  });

  group('HomeScreen', () {
    testWidgets('shows the empty state when there are no memories', (
      tester,
    ) async {
      await tester.pumpWidget(_appUnder(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text(AppConstants.emptyHomeMessage), findsOneWidget);
      expect(find.text(AppConstants.captureButtonLabel), findsWidgets);
    });

    testWidgets('the capture CTA opens the capture chooser', (tester) async {
      await tester.pumpWidget(_appUnder(const HomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppConstants.captureButtonLabel).first);
      await tester.pumpAndSettle();

      // All three capture routes are offered.
      expect(find.text('Take a photo'), findsOneWidget);
      expect(find.text('Choose a photo or screenshot'), findsOneWidget);
      expect(find.text('Type it in'), findsOneWidget);
    });
  });

  group('ConfirmScreen', () {
    testWidgets('saving a typed memory persists it and returns Home', (
      tester,
    ) async {
      final repository = InMemoryMemoryRepository();
      await tester.pumpWidget(
        _appUnder(const HomeScreen(), repository: repository),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppConstants.captureButtonLabel).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Type it in'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'What is it?'),
        'Car insurance',
      );
      await tester.tap(find.text('Save memory'));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.emptyHomeMessage), findsNothing);
      expect(find.text('Car insurance'), findsOneWidget);
    });

    testWidgets('refuses to save without a title', (tester) async {
      final repository = InMemoryMemoryRepository();
      await tester.pumpWidget(
        _appUnder(
          const ConfirmScreen(draft: CaptureDraft()),
          repository: repository,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save memory'));
      await tester.pumpAndSettle();

      expect(find.text('Give it a short title.'), findsOneWidget);
      expect(await repository.watchAll().first, isEmpty);
    });

    testWidgets('shows raw OCR text collapsed, and expands it on tap', (
      tester,
    ) async {
      const draft = CaptureDraft(rawText: 'Valid until 2026-11-17');
      await tester.pumpWidget(_appUnder(const ConfirmScreen(draft: draft)));
      await tester.pumpAndSettle();

      // Available, but not shouting a wall of OCR text at the user.
      expect(find.text('What the app read'), findsOneWidget);
      expect(find.text('Valid until 2026-11-17'), findsNothing);

      await tester.tap(find.text('What the app read'));
      await tester.pumpAndSettle();
      expect(find.text('Valid until 2026-11-17'), findsOneWidget);
    });

    testWidgets('offers each found date as a tappable suggestion', (
      tester,
    ) async {
      final draft = CaptureDraft(
        rawText: 'Renewal 03/04/2026',
        dateCandidates: DateCandidateFinder.find('Renewal 03/04/2026'),
      );
      await tester.pumpWidget(_appUnder(ConfirmScreen(draft: draft)));
      await tester.pumpAndSettle();

      // Ambiguous date => both readings offered, neither pre-selected.
      expect(find.byType(ChoiceChip), findsNWidgets(2));
      expect(find.text('No date set'), findsOneWidget);

      // Candidates are sorted oldest-first, so 4 March 2026 (the
      // month/day reading) comes before 3 April 2026 (the day/month one).
      // Chip labels carry the interpretation, e.g.
      // '04/03/2026  (month/day/year)'.
      await tester.tap(find.byType(ChoiceChip).last);
      await tester.pumpAndSettle();

      // The date field (not the chip) now reads the chosen date exactly.
      expect(find.text('03/04/2026'), findsOneWidget);
      expect(find.text('No date set'), findsNothing);
    });

    testWidgets('says so plainly when no dates were found', (tester) async {
      const draft = CaptureDraft(rawText: 'Thank you for your custom.');
      await tester.pumpWidget(_appUnder(const ConfirmScreen(draft: draft)));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('No dates found in this document'),
        findsOneWidget,
      );
      expect(find.byType(ChoiceChip), findsNothing);
    });
  });
}
