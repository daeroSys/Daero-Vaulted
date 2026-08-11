import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../domain/entities/subscription_tier.dart';

abstract class RevenueCatService {
  Future<void> initialize(String apiKey, String appUserId);
  Future<void> login(String appUserId);
  Future<void> logout();
  Future<void> restorePurchases();
  Stream<EntitlementDetails> get entitlementStream;
  EntitlementDetails get currentEntitlement;
}

class RevenueCatServiceImpl implements RevenueCatService {
  static const _premiumEntitlementIdentifier = 'premium';

  final _entitlementController =
      StreamController<EntitlementDetails>.broadcast();
  EntitlementDetails _currentEntitlement = EntitlementDetails.empty();

  RevenueCatServiceImpl() {
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
  }

  @override
  Stream<EntitlementDetails> get entitlementStream =>
      _entitlementController.stream;

  @override
  EntitlementDetails get currentEntitlement => _currentEntitlement;

  @override
  Future<void> initialize(String apiKey, String appUserId) async {
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

    PurchasesConfiguration configuration;
    if (defaultTargetPlatform == TargetPlatform.android) {
      configuration = PurchasesConfiguration(apiKey);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      configuration = PurchasesConfiguration(apiKey);
    } else {
      // RevenueCat does not support this platform yet
      return;
    }

    configuration.appUserID = appUserId;
    await Purchases.configure(configuration);

    final customerInfo = await Purchases.getCustomerInfo();
    _onCustomerInfoUpdated(customerInfo);
  }

  @override
  Future<void> login(String appUserId) async {
    try {
      final logInResult = await Purchases.logIn(appUserId);
      _onCustomerInfoUpdated(logInResult.customerInfo);
    } catch (e) {
      debugPrint('Error logging into RevenueCat: $e');
    }
  }

  // --- MOCK LOGIC FOR TESTING ---
  Future<void> mockPurchasePremium() async {
    _currentEntitlement = const EntitlementDetails(
      isActive: true,
      identifier: _premiumEntitlementIdentifier,
    );
    _entitlementController.add(_currentEntitlement);
  }
  // ------------------------------

  @override
  Future<void> logout() async {
    try {
      final customerInfo = await Purchases.logOut();
      _onCustomerInfoUpdated(customerInfo);
    } catch (e) {
      debugPrint('Error logging out of RevenueCat: $e');
    }
  }

  @override
  Future<void> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _onCustomerInfoUpdated(customerInfo);
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    final entitlement =
        customerInfo.entitlements.all[_premiumEntitlementIdentifier];

    _currentEntitlement = EntitlementDetails(
      isActive: entitlement?.isActive ?? false,
      identifier: _premiumEntitlementIdentifier,
      expirationDate: entitlement?.expirationDate != null
          ? DateTime.tryParse(entitlement!.expirationDate!)
          : null,
    );

    _entitlementController.add(_currentEntitlement);
  }
}
