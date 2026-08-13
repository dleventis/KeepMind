import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepmind/core/constants/app_constants.dart';
import 'package:keepmind/data/repositories/memory_repository_impl.dart';
import 'package:keepmind/domain/repositories/memory_repository.dart';
import 'package:keepmind/presentation/home/home_screen.dart';
import 'package:keepmind/presentation/providers/app_providers.dart';

/// All widget tests override [memoryRepositoryProvider] with the in-memory
/// fake — never the real Drift-backed one, which needs platform channels
/// (path_provider, flutter_secure_storage) that aren't available in a
/// plain widget test. See brief section 35: normal tests must never
/// require touching real platform/AI integrations.
Widget _appUnder(Widget home, {MemoryRepository? repository}) {
  return ProviderScope(
    overrides: [
      memoryRepositoryProvider.overrideWithValue(
        repository ?? InMemoryMemoryRepository(),
      ),
    ],
    child: MaterialApp(home: home),
  );
}

void main() {
  testWidgets(
    'HomeScreen shows the empty-state message and capture CTA when there are no memories',
    (tester) async {
      await tester.pumpWidget(_appUnder(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text(AppConstants.emptyHomeMessage), findsOneWidget);
      expect(find.text(AppConstants.captureButtonLabel), findsOneWidget);
    },
  );

  testWidgets(
    'Tapping the capture CTA navigates to the capture screen',
    (tester) async {
      await tester.pumpWidget(_appUnder(const HomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppConstants.captureButtonLabel));
      await tester.pumpAndSettle();

      expect(find.text('Remember something'), findsOneWidget);
    },
  );

  testWidgets(
    'Saving a memory from the capture screen returns to Home and lists it',
    (tester) async {
      final repository = InMemoryMemoryRepository();
      await tester.pumpWidget(
        _appUnder(const HomeScreen(), repository: repository),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppConstants.captureButtonLabel));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'What is it?'),
        'Car insurance',
      );
      await tester.tap(find.text('Save memory'));
      await tester.pumpAndSettle();

      // Back on Home, the empty state is gone and the new memory is listed.
      expect(find.text(AppConstants.emptyHomeMessage), findsNothing);
      expect(find.text('Car insurance'), findsOneWidget);
    },
  );
}
