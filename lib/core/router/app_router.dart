import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/search/presentation/search_results_screen.dart';
import '../../features/train/presentation/train_details_screen.dart';
import '../../features/train/presentation/route_details_screen.dart';
import '../../features/journey_planner/presentation/journey_planner_screen.dart';
import '../../features/station/presentation/station_details_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/about_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/search-results',
        builder: (context, state) => const SearchResultsScreen(),
      ),
      GoRoute(
        path: '/train-details/:id',
        builder: (context, state) => TrainDetailsScreen(trainId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/route-details/:id',
        builder: (context, state) => RouteDetailsScreen(routeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/journey-planner',
        builder: (context, state) => const JourneyPlannerScreen(),
      ),
      GoRoute(
        path: '/station-details/:id',
        builder: (context, state) => StationDetailsScreen(stationId: state.pathParameters['id']!),
      ),
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
  );
}
