import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepmind/core/constants/app_constants.dart';
import 'package:keepmind/data/repositories/memory_repository_impl.dart';
import 'package:keepmind/domain/repositories/memory_repository.dart';
import 'package:keepmind/domain/services/date_candidate_finder.dart';
import 'package:keepmind/presentation/capture/capture_draft.dart';
import 'package:keepmind/presentation/capture/confirm_screen.dart';
import 'package:keepmind/presentation/home/home_screen.dart';
import 'package:keepmind/presentation/providers/app_providers.dart';

import '../support/fakes.dart';

/// Widget tests override the repository and OCR providers with fakes —
/// never the real Drift-backed or ML Kit implementations, which need
/// platform channels (path_provider, flutter_secure_storage, ML Kit)
/// unavailable in a plain widget test. See brief §35.
Widget _appUnder(
  Widget home, {
  MemoryRepository? repository,
  FakeOcrService? ocr,
}) {
  return ProviderScope(
    overrides: [
      memoryRepositoryProvider.overrideWithValue(
        repository ?? InMemoryMemoryRepository(),
      ),
      ocrServiceProvider.overrideWithValue(ocr ?? FakeOcrService()),
    ],
    child: MaterialApp(home: home),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('shows the empty state when there are no memories',
        (tester) async {
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
    testWidgets('saving a typed memory persists it and returns Home',
        (tester) async {
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

    testWidgets('shows raw OCR text collapsed, and expands it on tap',
        (tester) async {
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

    testWidgets('offers each found date as a tappable suggestion',
        (tester) async {
      final draft = CaptureDraft(
        rawText: 'Renewal 03/04/2026',
        dateCandidates: DateCandidateFinder.find('Renewal 03/04/2026'),
      );
      await tester.pumpWidget(_appUnder(ConfirmScreen(draft: draft)));
      await tester.pumpAndSettle();

      // Ambiguous date => both readings offered, neither pre-selected.
      expect(find.byType(ChoiceChip), findsNWidgets(2));
      expect(find.text('No date set'), findsOneWidget);

      await tester.tap(find.byType(ChoiceChip).first);
      await tester.pumpAndSettle();

      // Tapping a suggestion fills the date field; 3 April sorts first.
      expect(find.text('03/04/2026'), findsWidgets);
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
