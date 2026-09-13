/// Subscription status for PackBuddy users
enum CustomerSubscriptionTier {
  free,
  premiumMonthly,
  premiumAnnual,
  premiumLifetime,
}

/// Abstract contract for RevenueCat In-App Purchases wrapper
abstract class IRevenueCatService {
  Future<void> initialize({required String apiKey});
  Future<bool> isPremiumUser();
  Future<CustomerSubscriptionTier> getSubscriptionTier();
  Future<bool> purchasePackage(String packageIdentifier);
  Future<bool> restorePurchases();
}

/// Mock payment service ready for development and testing without live API keys
class MockRevenueCatService implements IRevenueCatService {
  bool _isPremium = false;

  @override
  Future<void> initialize({required String apiKey}) async {
    // Mock initialization
  }

  @override
  Future<bool> isPremiumUser() async {
    return _isPremium;
  }

  @override
  Future<CustomerSubscriptionTier> getSubscriptionTier() async {
    return _isPremium ? CustomerSubscriptionTier.premiumLifetime : CustomerSubscriptionTier.free;
  }

  @override
  Future<bool> purchasePackage(String packageIdentifier) async {
    _isPremium = true;
    return true;
  }

  @override
  Future<bool> restorePurchases() async {
    return _isPremium;
  }
}

/// Production wrapper class for Purchases Flutter (ready for API key configuration)
class RevenueCatService implements IRevenueCatService {
  final bool isMock;
  final IRevenueCatService _mockService = MockRevenueCatService();

  RevenueCatService({this.isMock = true});

  @override
  Future<void> initialize({required String apiKey}) async {
    if (isMock) {
      return _mockService.initialize(apiKey: apiKey);
    }
    // Live purchases_flutter initialization will be configured when API keys are provided
  }

  @override
  Future<bool> isPremiumUser() async {
    if (isMock) return _mockService.isPremiumUser();
    return false;
  }

  @override
  Future<CustomerSubscriptionTier> getSubscriptionTier() async {
    if (isMock) return _mockService.getSubscriptionTier();
    return CustomerSubscriptionTier.free;
  }

  @override
  Future<bool> purchasePackage(String packageIdentifier) async {
    if (isMock) return _mockService.purchasePackage(packageIdentifier);
    return false;
  }

  @override
  Future<bool> restorePurchases() async {
    if (isMock) return _mockService.restorePurchases();
    return false;
  }
}
