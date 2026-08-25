import 'entitlements.dart';

/// One thing the user could buy, described in the app's own terms rather
/// than the billing SDK's — so no screen ever imports RevenueCat.
class PurchaseOption {
  const PurchaseOption({
    required this.id,
    required this.title,
    required this.priceString,
    this.description,
  });

  final String id;
  final String title;

  /// Already localized and currency-formatted by the store. Never
  /// re-format or convert this — the store's string is the one the user
  /// will actually be charged in.
  final String priceString;

  final String? description;
}

enum PurchaseOutcome {
  purchased,

  /// The user backed out. Explicitly not an error: showing an error
  /// dialog because someone changed their mind is obnoxious.
  cancelled,

  failed,
}

/// Entitlement + purchasing, behind an interface so the app can be run
/// and tested with no store attached (brief §35, §40).
abstract interface class EntitlementService {
  /// Safe to call more than once. Must not throw if the store is
  /// unreachable — the app has to keep working offline.
  Future<void> initialize();

  /// Current entitlements, updating when a purchase completes or the
  /// store reports a change (renewal, lapse, refund).
  Stream<Entitlements> watch();

  Future<Entitlements> current();

  /// What is available to buy. Empty when the store is unreachable or
  /// nothing is configured yet.
  Future<List<PurchaseOption>> availableOptions();

  Future<PurchaseOutcome> purchase(PurchaseOption option);

  /// Required by App Store review for any app selling a non-consumable
  /// or subscription — an app without a restore path gets rejected.
  Future<Entitlements> restore();
}
