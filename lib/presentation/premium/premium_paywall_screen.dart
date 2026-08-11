import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/premium_provider.dart';
import '../../core/services/revenuecat_service.dart';

class PremiumPaywallScreen extends ConsumerStatefulWidget {
  final String? featureName;

  const PremiumPaywallScreen({super.key, this.featureName});

  @override
  ConsumerState<PremiumPaywallScreen> createState() =>
      _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen> {
  bool _isLoading = false;

  Future<void> _purchasePremium() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // E.g. final revenueCat = ref.read(revenueCatServiceProvider);
      // await revenueCat.login(userId);
      // await Purchases.purchasePackage(package);

      await Future.delayed(const Duration(seconds: 2)); // Mock delay

      // MOCK PURCHASE SUCCESS
      final revenueCat =
          ref.read(revenueCatServiceProvider) as RevenueCatServiceImpl;
      await revenueCat.mockPurchasePremium();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Welcome to Premium!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to purchase: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final revenueCat = ref.read(revenueCatServiceProvider);
      await revenueCat.restorePurchases();

      if (mounted) {
        final isPremium = ref.read(isPremiumProvider);
        if (isPremium) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchases restored. Welcome back!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No active subscriptions found.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to restore: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade900, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 24),

                // Icon/Logo
                const Icon(Icons.diamond, color: Colors.amber, size: 80),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Vaulted Premium',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  widget.featureName != null
                      ? 'Unlock ${widget.featureName} and more'
                      : 'Serious about video management?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 48),

                // Features List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    children: const [
                      _FeatureRow(
                        icon: Icons.all_inclusive,
                        title: 'Unlimited saved items',
                      ),
                      _FeatureRow(
                        icon: Icons.folder_special,
                        title: 'Unlimited custom folders',
                      ),
                      _FeatureRow(
                        icon: Icons.devices,
                        title: 'Sync across all your devices',
                      ),
                      _FeatureRow(
                        icon: Icons.search,
                        title: 'Advanced full-text search',
                      ),
                    ],
                  ),
                ),

                // Purchase Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _purchasePremium,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Unlock Premium',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Restore Purchases
                TextButton(
                  onPressed: _isLoading ? null : _restorePurchases,
                  child: const Text(
                    'Restore Purchases',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FeatureRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
