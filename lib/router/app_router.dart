import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../widgets/placeholder_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/folders_screen.dart';
import '../application/providers/auth_provider.dart';

// Helper class to convert a Stream into a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(supabaseClientProvider).auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final supabase = ref.read(supabaseClientProvider);
      final session = supabase.auth.currentSession;
      final isAuthenticated = session != null;
      
      final isLoggingIn = state.matchedLocation == '/authentication';
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) {
        if (isAuthenticated) {
          return '/home';
        } else {
          return '/authentication';
        }
      }

      if (!isAuthenticated && !isLoggingIn) {
        return '/authentication';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const FoldersScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const PlaceholderScreen(title: 'Settings'),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const PlaceholderScreen(title: 'Profile'),
      ),
      GoRoute(
        path: '/authentication',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PlaceholderScreen(title: 'Premium'),
      ),
      GoRoute(
        path: '/content',
        builder: (context, state) => const PlaceholderScreen(title: 'Content'),
      ),
      GoRoute(
        path: '/folders',
        builder: (context, state) => const FoldersScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const PlaceholderScreen(title: 'Search'),
      ),
    ],
  );
});
