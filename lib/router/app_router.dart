import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../widgets/placeholder_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/folders_screen.dart';
import '../presentation/screens/folder_details_screen.dart';
import '../presentation/screens/search_screen.dart';
import '../presentation/widgets/main_navigation_scaffold.dart';
import '../application/providers/auth_provider.dart';

// Helper class to convert a Stream into a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription _subscription;

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

      if (!isAuthenticated && !isLoggingIn && !isSplash) {
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
        path: '/authentication',
        builder: (context, state) => const LoginScreen(),
      ),
      // ShellRoute for Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/folders',
            builder: (context, state) => const FoldersScreen(),
          ),
          GoRoute(
            path: '/folders/:id',
            builder: (context, state) {
              final folderId = state.pathParameters['id']!;
              return FolderDetailsScreen(folderId: folderId);
            },
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/premium',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Premium'),
          ),
          GoRoute(
            path: '/content',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Content'),
          ),
        ],
      ),
    ],
  );
});
