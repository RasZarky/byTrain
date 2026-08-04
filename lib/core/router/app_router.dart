import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/main_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/search/presentation/search_results_screen.dart';
import '../../features/train/presentation/train_details_screen.dart';
import '../../features/train/presentation/route_details_screen.dart';
import '../../features/journey_planner/presentation/journey_planner_screen.dart';
import '../../features/station/presentation/station_details_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/about_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellHome',
);
final _shellNavigatorSearchKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellSearch',
);
final _shellNavigatorPlanKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellPlan',
);
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellSettings',
);

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSearchKey,
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorPlanKey,
            routes: [
              GoRoute(
                path: '/journey-planner',
                builder: (context, state) => const JourneyPlannerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Detail routes that should probably be on top of the shell
      GoRoute(
        path: '/search-results',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchResultsScreen(),
      ),
      GoRoute(
        path: '/train-details/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            TrainDetailsScreen(trainId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/route-details/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            RouteDetailsScreen(routeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/station-details/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            StationDetailsScreen(stationId: state.pathParameters['id']!),
      ),
    ],
  );
}
