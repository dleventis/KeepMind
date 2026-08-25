/// What the user is entitled to. Deliberately a tiny domain concept with
/// no RevenueCat types in it, so the rest of the app never imports the
/// billing SDK and the business model can change without touching UI —
/// brief §40, "do not tightly couple premium features to UI components".
enum EntitlementTier { free, premium }

class Entitlements {
  const Entitlements(this.tier);

  final EntitlementTier tier;

  /// The safe default before the store has been reached. Starting
  /// pessimistic (free) rather than optimistic means a network failure
  /// can never silently hand out premium — and because the free tier is
  /// fully usable, the cost of being briefly wrong is nil.
  static const Entitlements free = Entitlements(EntitlementTier.free);
  static const Entitlements premium = Entitlements(EntitlementTier.premium);

  bool get isPremium => tier == EntitlementTier.premium;
}

/// Free-tier limits, as pure data + pure functions so the rules are
/// unit-testable without a store, a network, or a device.
class FreeTierLimits {
  FreeTierLimits._();

  /// Chosen to be genuinely useful rather than a teaser: a passport, a
  /// driving licence, car insurance, an MOT, two subscriptions and a
  /// couple of warranties still fit inside the free tier.
  static const int maxActiveMemories = 10;

  /// Whether another memory may be created.
  ///
  /// The cap applies ONLY to creating new memories. Reading, editing,
  /// and deleting what the user already saved is never gated — including
  /// when they are over the limit after a subscription lapses. Holding
  /// someone's own passport expiry hostage to a renewal would be exactly
  /// the dark pattern the brief forbids (§53), quite apart from being a
  /// terrible thing to do to a person who trusted the app with it.
  static bool canCreateMemory({
    required int currentCount,
    required bool isPremium,
  }) {
    if (isPremium) return true;
    return currentCount < maxActiveMemories;
  }

  /// How many more the user may add, or null when unlimited.
  static int? remainingSlots({
    required int currentCount,
    required bool isPremium,
  }) {
    if (isPremium) return null;
    final left = maxActiveMemories - currentCount;
    return left < 0 ? 0 : left;
  }

  /// Whether to start warning that the free tier is nearly full. Shown
  /// as a quiet note, not a nag — see the UI that consumes it.
  static bool shouldWarn({required int currentCount, required bool isPremium}) {
    if (isPremium) return false;
    return currentCount >= maxActiveMemories - 2;
  }
}
