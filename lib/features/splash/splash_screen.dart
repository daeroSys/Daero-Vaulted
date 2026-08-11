import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vaulted/application/providers/auth_provider.dart';
import 'package:vaulted/application/providers/sync_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startAnimationAndNavigate();
  }

  Future<void> _startAnimationAndNavigate() async {
    // Wait for the animation to finish (2 seconds)
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final supabase = ref.read(supabaseClientProvider);
    final session = supabase.auth.currentSession;
    final isAuthenticated = session != null;

    if (isAuthenticated) {
      final syncService = ref.read(syncServiceProvider);
      await syncService.syncDown(session.user.id);
      if (!mounted) return;
      context.go('/home');
    } else {
      context.go('/authentication');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child:
                Image.asset('assets/vaultedlogo.jpg', width: 120, height: 120)
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scaleXY(
                      end: 1.1,
                      duration: 1.seconds,
                      curve: Curves.easeInOut,
                    )
                    .shimmer(
                      duration: 2.seconds,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'developed by',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ).animate().fade(delay: 500.ms, duration: 500.ms),
                const SizedBox(height: 4),
                Text(
                      'D Λ Ξ R O',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 4,
                      ),
                    )
                    .animate()
                    .fade(delay: 500.ms, duration: 500.ms)
                    .slideY(begin: 0.5, end: 0, curve: Curves.easeOut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
