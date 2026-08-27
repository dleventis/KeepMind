import 'entitlements.dart';

/// How often a subscription bills.
///
/// Mirrors the store's package types in the app's own vocabulary so no
/// screen has to import the billing SDK to know whether it is showing a
/// monthly or a yearly plan.
enum BillingPeriod {
  weekly,
  monthly,
  twoMonth,
  threeMonth,
  sixMonth,
  annual,
  lifetime,
  unknown,
}

extension BillingPeriodLabels on BillingPeriod {
  /// What to call the plan itself, e.g. the label on its button.
  String get planLabel => switch (this) {
    BillingPeriod.weekly => 'Weekly',
    BillingPeriod.monthly => 'Monthly',
    BillingPeriod.twoMonth => 'Every 2 months',
    BillingPeriod.threeMonth => 'Every 3 months',
    BillingPeriod.sixMonth => 'Every 6 months',
    BillingPeriod.annual => 'Yearly',
    BillingPeriod.lifetime => 'Lifetime',
    BillingPeriod.unknown => 'Premium',
  };

  /// The noun after "per", or null where "per X" does not apply.
  /// Lifetime is not a recurring period, so it has none.
  String? get perUnit => switch (this) {
    BillingPeriod.weekly => 'week',
    BillingPeriod.monthly => 'month',
    BillingPeriod.twoMonth => '2 months',
    BillingPeriod.threeMonth => '3 months',
    BillingPeriod.sixMonth => '6 months',
    BillingPeriod.annual => 'year',
    BillingPeriod.lifetime => null,
    BillingPeriod.unknown => null,
  };
}

enum IntroPeriodUnit { day, week, month, year, unknown }

/// An introductory offer attached to a subscription — a free trial, or a
/// reduced price for the first few periods.
///
/// App Store review (Guideline 3.1.2) requires the offer and what
/// follows it to be stated where the user can see them before buying.
/// Showing only the headline price while a trial exists is both a
/// rejection risk and, more to the point, misleading.
class IntroOffer {
  const IntroOffer({
    required this.priceString,
    required this.isFree,
    required this.unit,
    required this.unitCount,
    required this.cycles,
  });

  /// The store's own formatted string for the introductory price.
  final String priceString;

  /// True when the introductory price is zero — a free trial rather than
  /// a discount.
  final bool isFree;

  final IntroPeriodUnit unit;

  /// Units in one introductory period, e.g. 2 for a two-week trial.
  final int unitCount;

  /// How many introductory periods before the full price begins. Free
  /// trials are a single cycle.
  final int cycles;

  String _unitWord(int n) {
    final singular = switch (unit) {
      IntroPeriodUnit.day => 'day',
      IntroPeriodUnit.week => 'week',
      IntroPeriodUnit.month => 'month',
      IntroPeriodUnit.year => 'year',
      IntroPeriodUnit.unknown => 'period',
    };
    return n == 1 ? singular : '${singular}s';
  }

  /// A short, literal description of the offer — "2 weeks free", or
  /// "€0.99 for the first 3 months". Deliberately states the duration
  /// rather than shouting FREE.
  String get summary {
    if (isFree) {
      final n = unitCount * (cycles < 1 ? 1 : cycles);
      return '$n ${_unitWord(n)} free';
    }
    final n = unitCount * (cycles < 1 ? 1 : cycles);
    return '$priceString for the first $n ${_unitWord(n)}';
  }
}

/// One thing the user could buy, described in the app's own terms rather
/// than the billing SDK's — so no screen ever imports RevenueCat.
class PurchaseOption {
  const PurchaseOption({
    required this.id,
    required this.title,
    required this.priceString,
    this.period = BillingPeriod.unknown,
    this.introOffer,
    this.pricePerMonthString,
    this.description,
  });

  final String id;

  /// The store's product title. Note that on iOS this often arrives with
  /// the app name appended, so screens generally prefer
  /// `period.planLabel` and keep this as a fallback.
  final String title;

  /// Already localized and currency-formatted by the store. Never
  /// re-format or convert this — the store's string is the one the user
  /// will actually be charged in.
  final String priceString;

  final BillingPeriod period;

  /// Null when there is no introductory offer on this product.
  final IntroOffer? introOffer;

  /// The store's own per-month equivalent, where it provides one. Shown
  /// beside longer plans so the comparison is arithmetic the user does
  /// not have to do. Null on plans where it is meaningless.
  final String? pricePerMonthString;

  final String? description;

  /// What to call this plan on screen.
  String get displayTitle =>
      period == BillingPeriod.unknown ? title : period.planLabel;

  /// The recurring price, phrased per period where that applies.
  String get priceLine {
    final unit = period.perUnit;
    return unit == null ? priceString : '$priceString per $unit';
  }
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
