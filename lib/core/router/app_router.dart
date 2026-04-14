import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/farmacia.dart';
import '../../presentation/screens/detail_screen.dart';
import '../../presentation/screens/favorites_screen.dart';
import '../../presentation/screens/list_screen.dart';
import '../../presentation/screens/map_screen.dart';
import '../../presentation/screens/search_screen.dart';

/// GoRouter configuration for the app
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      // Map Screen (home)
      GoRoute(
        path: '/',
        name: 'map',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MapScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // List Screen
      GoRoute(
        path: '/list',
        name: 'list',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ListScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),

      // Search Screen
      GoRoute(
        path: '/search',
        name: 'search',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SearchScreen(),
          transitionsBuilder: _fadeSlideTransition,
        ),
      ),

      // Detail Screen
      GoRoute(
        path: '/detail/:id',
        name: 'detail',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          final farmacia = state.extra as Farmacia?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: DetailScreen(
              farmaciaId: id,
              farmacia: farmacia,
            ),
            transitionsBuilder: _slideTransition,
          );
        },
      ),

      // Favorites Screen
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const FavoritosScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
    ],
  );

  // ─── Transition Builders ───────────────────────────────────

  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  static Widget _slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final tween = Tween(begin: const Offset(0.0, 0.1), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic));

    final fadeTween = Tween(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeIn));

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation.drive(fadeTween),
        child: child,
      ),
    );
  }

  static Widget _fadeSlideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fadeTween = Tween(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeIn));

    final slideTween = Tween(begin: const Offset(0.0, -0.03), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: animation.drive(fadeTween),
      child: SlideTransition(
        position: animation.drive(slideTween),
        child: child,
      ),
    );
  }
}
