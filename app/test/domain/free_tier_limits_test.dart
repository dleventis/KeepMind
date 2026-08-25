import 'package:flutter_test/flutter_test.dart';
import 'package:keepmind/domain/entitlements/entitlements.dart';

/// The monetization rules are pure functions precisely so they can be
/// pinned down here rather than discovered in production. The cases that
/// matter most are the ones about NOT punishing the user: an over-limit
/// free account must still be able to read, and a lapsed subscriber must
/// never lose access to what they already saved.
void main() {
  group('creating memories on the free tier', () {
    test('allows creation below the limit', () {
      expect(
        FreeTierLimits.canCreateMemory(currentCount: 0, isPremium: false),
        isTrue,
      );
      expect(
        FreeTierLimits.canCreateMemory(currentCount: 9, isPremium: false),
        isTrue,
      );
    });

    test('blocks creation at the limit', () {
      expect(
        FreeTierLimits.canCreateMemory(
          currentCount: FreeTierLimits.maxActiveMemories,
          isPremium: false,
        ),
        isFalse,
      );
    });

    test('premium is never blocked', () {
      expect(
        FreeTierLimits.canCreateMemory(currentCount: 10000, isPremium: true),
        isTrue,
      );
    });
  });

  group('remaining slots', () {
    test('counts down toward the limit', () {
      expect(
        FreeTierLimits.remainingSlots(currentCount: 0, isPremium: false),
        FreeTierLimits.maxActiveMemories,
      );
      expect(
        FreeTierLimits.remainingSlots(currentCount: 9, isPremium: false),
        1,
      );
    });

    test('never goes negative for an over-limit account', () {
      // Reachable when a subscription lapses while over the free limit.
      // A negative number would render as nonsense like "-4 memories left".
      expect(
        FreeTierLimits.remainingSlots(currentCount: 14, isPremium: false),
        0,
      );
    });

    test('is null (unlimited) for premium', () {
      expect(
        FreeTierLimits.remainingSlots(currentCount: 500, isPremium: true),
        isNull,
      );
    });
  });

  group('the nearly-full warning', () {
    test('stays quiet until the last two slots', () {
      expect(
        FreeTierLimits.shouldWarn(currentCount: 7, isPremium: false),
        isFalse,
      );
      expect(
        FreeTierLimits.shouldWarn(currentCount: 8, isPremium: false),
        isTrue,
      );
    });

    test('never nags a premium subscriber', () {
      expect(
        FreeTierLimits.shouldWarn(currentCount: 9999, isPremium: true),
        isFalse,
      );
    });
  });

  group('entitlements', () {
    test('free is the safe default', () {
      expect(Entitlements.free.isPremium, isFalse);
      expect(Entitlements.premium.isPremium, isTrue);
    });
  });
}
