import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/core_providers.dart';

// Screens
import 'features/home/presentation/screens/home_screen.dart';
import 'features/search/presentation/screens/destination_search_screen.dart';
import 'features/search/presentation/screens/map_selection_screen.dart';
import 'features/tracking/presentation/screens/tracking_screen.dart';
import 'features/alert/presentation/screens/alert_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/favorites/presentation/screens/favorites_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create temporary container to initialize services before running app
  final container = ProviderContainer();

  try {
    // 1. Initialize Isar Database
    await container.read(isarServiceProvider).init();
    
    // 2. Initialize Notification service channel configuration
    await container.read(notificationServiceProvider).init();
  } catch (e) {
    debugPrint("Failed to initialize core services: $e");
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WereachApp(),
    ),
  );
}

class WereachApp extends ConsumerWidget {
  const WereachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Premium Apple/Linear page transition config
    final GoRouter router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const DestinationSearchScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Smooth iOS style slide transition
              const begin = Offset(0.0, 1.0); // slide up from bottom
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          ),
        ),
        GoRoute(
          path: '/map-select',
          pageBuilder: (context, state) {
            final Map<String, dynamic>? locationArgs = state.extra as Map<String, dynamic>?;
            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: MapSelectionScreen(initialLocation: locationArgs),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0); // slide from right
                const end = Offset.zero;
                const curve = Curves.easeOutCubic;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
            );
          },
        ),
        GoRoute(
          path: '/tracking',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const TrackingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/alert',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const AlertScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Warning screen scale pop-up animation
              return ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0); // slide up settings sheet
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          ),
        ),
        GoRoute(
          path: '/favorites',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const FavoritesScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0); // slide from right
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          ),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Wereach',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
