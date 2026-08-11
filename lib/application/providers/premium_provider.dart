import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/revenuecat_service.dart';
import '../../domain/entities/subscription_tier.dart';

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatServiceImpl();
});

final entitlementProvider = StreamProvider<EntitlementDetails>((ref) {
  final service = ref.watch(revenueCatServiceProvider);
  return service.entitlementStream;
});

final isPremiumProvider = Provider<bool>((ref) {
  final entitlement = ref.watch(entitlementProvider).value;
  return entitlement?.isActive ?? false;
});
