import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../domain/entitlements/entitlement_service.dart';
import '../../domain/entitlements/entitlements.dart';

/// RevenueCat-backed entitlements.
///
/// Every RevenueCat type is confined to this file; the rest of the app
/// sees only `Entitlements` and `PurchaseOption`. Swapping billing
/// providers, or running with no store at all, means replacing this class
/// and nothing else (brief §40).
///
/// Failure policy throughout: if the store cannot be reached, fall back
/// to the free tier and keep going. Mindkeep is local-first — a user with
/// no network must still be able to open the app, read their memories,
/// and get their reminders.
class RevenueCatEntitlementService implements EntitlementService {
  RevenueCatEntitlementService({
    String? iosApiKey,
    String? androidApiKey,
    this.entitlementId = 'premium',
  }) : _iosApiKey = iosApiKey ?? _iosKeyFromEnvironment,
       _androidApiKey = androidApiKey ?? _androidKeyFromEnvironment;

  /// The entitlement identifier configured in the RevenueCat dashboard.
  final String entitlementId;

  final String _iosApiKey;
  final String _androidApiKey;

  /// Supplied at build time rather than committed:
  ///   flutter run --dart-define=REVENUECAT_IOS_KEY=appl_xxx
  ///
  /// RevenueCat's SDK keys are public by design, so this is not the same
  /// class of secret as a provider API key. It is kept out of the repo
  /// anyway — brief §45, "never commit secrets", is a habit worth keeping
  /// unconditionally rather than one to reason about case by case.
  static const String _iosKeyFromEnvironment = String.fromEnvironment(
    'REVENUECAT_IOS_KEY',
  );
  static const String _androidKeyFromEnvironment = String.fromEnvironment(
    'REVENUECAT_ANDROID_KEY',
  );

  final _controller = StreamController<Entitlements>.broadcast();
  Future<void>? _initialization;
  Entitlements _latest = Entitlements.free;
  bool _configured = false;

  /// True when no API key was supplied at build time. The app then runs
  /// entirely on the free tier with no paywall — which is what a
  /// contributor cloning the repo without RevenueCat credentials should
  /// get, rather than a crash.
  bool get isConfigured => _configured;

  @override
  Future<void> initialize() => _initialization ??= _doInitialize();

  Future<void> _doInitialize() async {
    final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;
    if (apiKey.isEmpty) {
      _emit(Entitlements.free);
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.warn);
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;

      Purchases.addCustomerInfoUpdateListener((info) {
        // Fires on renewal, lapse, refund, and after a purchase — so a
        // subscription ending is reflected without the user relaunching.
        _emit(_fromCustomerInfo(info));
      });

      _emit(_fromCustomerInfo(await Purchases.getCustomerInfo()));
    } catch (_) {
      // Store unreachable or misconfigured: stay on the free tier.
      _emit(Entitlements.free);
    }
  }

  @override
  Stream<Entitlements> watch() async* {
    yield _latest;
    yield* _controller.stream;
  }

  @override
  Future<Entitlements> current() async {
    await initialize();
    return _latest;
  }

  @override
  Future<List<PurchaseOption>> availableOptions() async {
    await initialize();
    if (!_configured) return const [];

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return const [];

      return current.availablePackages.map(_toOption).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<PurchaseOutcome> purchase(PurchaseOption option) async {
    await initialize();
    if (!_configured) return PurchaseOutcome.failed;

    try {
      final offerings = await Purchases.getOfferings();
      final packages = offerings.current?.availablePackages ?? const [];
      final match = packages.where((p) => p.identifier == option.id);
      if (match.isEmpty) return PurchaseOutcome.failed;

      // `purchasePackage` is deprecated in favour of the unified
      // `purchase(PurchaseParams)` entry point. PurchaseParams has no
      // unnamed constructor — only one named constructor per purchase
      // type (`.package`, `.storeProduct`, `.subscriptionOption`) — and
      // the package argument is positional, not named.
      final result = await Purchases.purchase(
        PurchaseParams.package(match.first),
      );
      _emit(_fromCustomerInfo(result.customerInfo));
      return PurchaseOutcome.purchased;
    } on PlatformException catch (e) {
      // Backing out of the payment sheet is a normal thing to do, not an
      // error to shout about.
      final code = PurchasesErrorHelper.getErrorCode(e);
      return code == PurchasesErrorCode.purchaseCancelledError
          ? PurchaseOutcome.cancelled
          : PurchaseOutcome.failed;
    } catch (_) {
      return PurchaseOutcome.failed;
    }
  }

  @override
  Future<Entitlements> restore() async {
    await initialize();
    if (!_configured) return Entitlements.free;

    try {
      final info = await Purchases.restorePurchases();
      final restored = _fromCustomerInfo(info);
      _emit(restored);
      return restored;
    } catch (_) {
      return _latest;
    }
  }

  PurchaseOption _toOption(Package p) => PurchaseOption(
    id: p.identifier,
    title: p.storeProduct.title,
    priceString: p.storeProduct.priceString,
    period: _periodOf(p.packageType),
    introOffer: _introOf(p.storeProduct.introductoryPrice),
    // Only worth showing where it differs from the headline price;
    // repeating "€1.99 per month" underneath "€1.99 per month" is noise.
    pricePerMonthString: p.packageType == PackageType.monthly
        ? null
        : p.storeProduct.pricePerMonthString,
    description: p.storeProduct.description,
  );

  BillingPeriod _periodOf(PackageType type) => switch (type) {
    PackageType.weekly => BillingPeriod.weekly,
    PackageType.monthly => BillingPeriod.monthly,
    PackageType.twoMonth => BillingPeriod.twoMonth,
    PackageType.threeMonth => BillingPeriod.threeMonth,
    PackageType.sixMonth => BillingPeriod.sixMonth,
    PackageType.annual => BillingPeriod.annual,
    PackageType.lifetime => BillingPeriod.lifetime,
    PackageType.custom || PackageType.unknown => BillingPeriod.unknown,
  };

  /// `introductoryPrice` is the iOS path; `subscriptionOptions` and
  /// `defaultOption` are documented as Google Play only and are null
  /// here, so there is nothing to fall back to on this platform.
  ///
  /// The SDK does not expose an explicit "this is a free trial" flag, so
  /// a zero price is what distinguishes a trial from a discounted intro
  /// offer.
  IntroOffer? _introOf(IntroductoryPrice? intro) {
    if (intro == null) return null;
    return IntroOffer(
      priceString: intro.priceString,
      isFree: intro.price == 0,
      unit: _introUnitOf(intro.periodUnit),
      unitCount: intro.periodNumberOfUnits,
      cycles: intro.cycles,
    );
  }

  IntroPeriodUnit _introUnitOf(PeriodUnit unit) => switch (unit) {
    PeriodUnit.day => IntroPeriodUnit.day,
    PeriodUnit.week => IntroPeriodUnit.week,
    PeriodUnit.month => IntroPeriodUnit.month,
    PeriodUnit.year => IntroPeriodUnit.year,
    PeriodUnit.unknown => IntroPeriodUnit.unknown,
  };

  Entitlements _fromCustomerInfo(CustomerInfo info) {
    final active = info.entitlements.all[entitlementId]?.isActive ?? false;
    return active ? Entitlements.premium : Entitlements.free;
  }

  void _emit(Entitlements entitlements) {
    _latest = entitlements;
    if (!_controller.isClosed) _controller.add(entitlements);
  }

  void dispose() => _controller.close();
}
