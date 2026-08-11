import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/premium_provider.dart';
import 'premium_paywall_screen.dart';

class PremiumGateWidget extends ConsumerWidget {
  final Widget child;
  final Widget? lockedChild;
  final VoidCallback? onLockedTapOverride;
  final bool showLockIcon;
  final String featureName;

  const PremiumGateWidget({
    super.key,
    required this.child,
    this.lockedChild,
    this.onLockedTapOverride,
    this.showLockIcon = true,
    this.featureName = 'this feature',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    if (isPremium) {
      return child;
    }

    if (lockedChild != null) {
      return GestureDetector(
        onTap: onLockedTapOverride ?? () => _showPaywall(context),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(opacity: 0.5, child: lockedChild!),
            if (showLockIcon)
              const Icon(Icons.lock, color: Colors.amber, size: 24),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onLockedTapOverride ?? () => _showPaywall(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0.5, child: IgnorePointer(child: child)),
          if (showLockIcon)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock, color: Colors.amber, size: 20),
            ),
        ],
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PremiumPaywallScreen(featureName: featureName),
        fullscreenDialog: true,
      ),
    );
  }
}
