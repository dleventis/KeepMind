import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepmind/core/constants/app_constants.dart';
import 'package:keepmind/presentation/home/home_screen.dart';

void main() {
  testWidgets(
    'HomeScreen shows the empty-state message and capture CTA',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: HomeScreen()),
        ),
      );

      // Let the memoriesStreamProvider's first async value settle.
      await tester.pumpAndSettle();

      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text(AppConstants.emptyHomeMessage), findsOneWidget);
      expect(find.text(AppConstants.captureButtonLabel), findsOneWidget);
    },
  );

  testWidgets(
    'Tapping the capture CTA navigates to the capture placeholder screen',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppConstants.captureButtonLabel));
      await tester.pumpAndSettle();

      expect(find.text('Remember something'), findsOneWidget);
    },
  );
}
