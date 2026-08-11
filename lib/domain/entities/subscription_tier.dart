enum SubscriptionTier {
  free,
  premium;

  bool get isPremium => this == SubscriptionTier.premium;
}

class EntitlementDetails {
  final bool isActive;
  final String identifier;
  final DateTime? expirationDate;

  const EntitlementDetails({
    required this.isActive,
    required this.identifier,
    this.expirationDate,
  });

  factory EntitlementDetails.empty() =>
      const EntitlementDetails(isActive: false, identifier: '');
}
