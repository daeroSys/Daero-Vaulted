import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../widgets/placeholder_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const PlaceholderScreen(title: 'Home'),
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
      builder: (context, state) => const PlaceholderScreen(title: 'Authentication'),
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
      builder: (context, state) => const PlaceholderScreen(title: 'Folders'),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const PlaceholderScreen(title: 'Search'),
    ),
  ],
);
