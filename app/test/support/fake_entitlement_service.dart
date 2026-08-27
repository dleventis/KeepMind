import 'dart:async';

import 'package:keepmind/domain/entitlements/entitlement_service.dart';
import 'package:keepmind/domain/entitlements/entitlements.dart';

/// In-memory [EntitlementService] so widget tests never touch a real
/// store. Defaults to free, which is what a test should assume unless it
/// is specifically about premium behaviour.
class FakeEntitlementService implements EntitlementService {
  FakeEntitlementService({Entitlements initial = Entitlements.free})
    : _current = initial;

  Entitlements _current;
  final _controller = StreamController<Entitlements>.broadcast();

  /// Mirrors what App Store Connect actually serves: a monthly plan and
  /// a yearly one carrying a two-week free trial. Tests that only care
  /// about entitlement state can ignore this; the paywall tests depend
  /// on it being shaped like the real thing.
  List<PurchaseOption> options = const [
    PurchaseOption(
      id: 'premium_monthly',
      title: 'Mindkeep Premium Monthly',
      priceString: '1.99 EUR',
      period: BillingPeriod.monthly,
    ),
    PurchaseOption(
      id: 'premium_annual',
      title: 'Mindkeep Premium Annual',
      priceString: '14.99 EUR',
      period: BillingPeriod.annual,
      pricePerMonthString: '1.25 EUR',
      introOffer: IntroOffer(
        priceString: '0.00 EUR',
        isFree: true,
        unit: IntroPeriodUnit.week,
        unitCount: 2,
        cycles: 1,
      ),
    ),
  ];

  PurchaseOutcome nextOutcome = PurchaseOutcome.purchased;
  int purchaseCalls = 0;
  int restoreCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Stream<Entitlements> watch() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<Entitlements> current() async => _current;

  @override
  Future<List<PurchaseOption>> availableOptions() async => options;

  @override
  Future<PurchaseOutcome> purchase(PurchaseOption option) async {
    purchaseCalls++;
    if (nextOutcome == PurchaseOutcome.purchased) {
      _current = Entitlements.premium;
      _controller.add(_current);
    }
    return nextOutcome;
  }

  @override
  Future<Entitlements> restore() async {
    restoreCalls++;
    return _current;
  }

  void dispose() => _controller.close();
}
