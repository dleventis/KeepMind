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

  List<PurchaseOption> options = const [
    PurchaseOption(
      id: 'premium_monthly',
      title: 'KeepMind Premium',
      priceString: '2.99 EUR',
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
