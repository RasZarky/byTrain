import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:by_train/core/data/saved_journeys_store.dart';
import 'package:by_train/features/home/presentation/bloc/home_bloc.dart';
import 'package:by_train/features/home/presentation/home_screen.dart';
import 'package:by_train/features/journey_planner/domain/models/saved_journey.dart';

SavedJourney _journey(DateTime departure, {String trainId = '42DN'}) {
  return SavedJourney(
    trainId: trainId,
    trainNumber: trainId,
    trainName: 'Karakoram Express',
    fromStationId: 'lahore jn',
    fromName: 'Lahore Junction',
    fromCode: 'LHR',
    toStationId: 'karachi cantt',
    toName: 'Karachi Cantt',
    toCode: 'KC',
    departureTime: departure,
    arrivalTime: departure.add(const Duration(hours: 19)),
    savedAt: DateTime(2026, 8, 12),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget app(HomeBloc bloc) {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/journey-planner',
          builder: (context, state) => const Scaffold(body: Text('PLANNER')),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const Scaffold(body: Text('SEARCH')),
        ),
        GoRoute(
          path: '/train-details/:id',
          builder: (context, state) => const Scaffold(body: Text('DETAILS')),
        ),
      ],
    );
    return BlocProvider.value(
      value: bloc,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('Home renders an empty state when nothing is saved', (
    tester,
  ) async {
    final bloc = HomeBloc(savedJourneysStore: SavedJourneysStore())
      ..add(LoadHomeData());
    await tester.pumpWidget(app(bloc));
    await tester.pumpAndSettle();

    expect(find.text('Upcoming Journeys'), findsOneWidget);
    expect(find.text('No upcoming journeys yet'), findsOneWidget);
    expect(find.text('Plan a Journey'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Home lists saved upcoming journeys', (tester) async {
    final store = SavedJourneysStore();
    await store.add(_journey(DateTime.now().add(const Duration(days: 2))));
    final bloc = HomeBloc(savedJourneysStore: store)..add(LoadHomeData());

    await tester.pumpWidget(app(bloc));
    await tester.pumpAndSettle();

    expect(find.text('No upcoming journeys yet'), findsNothing);
    expect(find.textContaining('Karakoram Express'), findsWidgets);
    expect(find.textContaining('Lahore Junction'), findsWidgets);
    expect(find.textContaining('Karachi Cantt'), findsWidgets);
  });
}
