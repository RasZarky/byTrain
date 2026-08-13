import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:by_train/core/data/pakrail_repository.dart';
import 'package:by_train/features/search/presentation/bloc/search_bloc.dart';
import 'package:by_train/features/search/presentation/search_screen.dart';
import 'package:by_train/features/train/presentation/widgets/train_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads all trains, stations and routes by default', () async {
    final bloc = SearchBloc()..add(LoadTrains());
    await bloc.stream.firstWhere((s) => !s.isLoading);

    expect(bloc.state.allTrains.length, greaterThanOrEqualTo(20));
    expect(bloc.state.filteredTrains.length, bloc.state.allTrains.length);
    expect(bloc.state.allStations.length, greaterThanOrEqualTo(100));
    expect(bloc.state.stationResults.length, bloc.state.allStations.length);
    expect(bloc.state.allRoutes.length, greaterThanOrEqualTo(20));
    expect(bloc.state.routeResults.length, bloc.state.allRoutes.length);
    expect(bloc.state.contentFilter, 'All');
    await bloc.close();
  });

  test('typing a query filters stations, routes and trains', () async {
    final bloc = SearchBloc()..add(LoadTrains());
    await bloc.stream.firstWhere((s) => !s.isLoading);

    bloc.add(const UpdateSearchQuery('Multan'));
    await bloc.stream.firstWhere((s) => s.searchQuery == 'Multan');
    expect(bloc.state.isSearching, isTrue);
    expect(bloc.state.stationResults, isNotEmpty);
    expect(
      bloc.state.stationResults.every((s) => s.name.contains('Multan')),
      isTrue,
    );
    await bloc.close();
  });

  test('a corridor query returns real routes', () async {
    final bloc = SearchBloc()..add(LoadTrains());
    await bloc.stream.firstWhere((s) => !s.isLoading);

    bloc.add(const UpdateSearchQuery('Lahore to Karachi'));
    await bloc.stream.firstWhere((s) => s.searchQuery == 'Lahore to Karachi');
    expect(bloc.state.routeResults, isNotEmpty);
    expect(
      bloc.state.routeResults.any((j) => j.train.number == '42DN'),
      isTrue,
    );
    await bloc.close();
  });

  test('a train-name query surfaces matching routes too', () async {
    final bloc = SearchBloc()..add(LoadTrains());
    await bloc.stream.firstWhere((s) => !s.isLoading);

    bloc.add(const UpdateSearchQuery('Karakoram'));
    await bloc.stream.firstWhere((s) => s.searchQuery == 'Karakoram');
    expect(bloc.state.routeResults, isNotEmpty);
    expect(
      bloc.state.routeResults.every((j) => j.train.name.contains('Karakoram')),
      isTrue,
    );
    await bloc.close();
  });

  test('clearing search restores the full lists', () async {
    final bloc = SearchBloc()..add(LoadTrains());
    await bloc.stream.firstWhere((s) => !s.isLoading);

    bloc.add(const UpdateSearchQuery('Multan'));
    await bloc.stream.firstWhere((s) => s.searchQuery == 'Multan');
    expect(
      bloc.state.stationResults.length,
      lessThan(bloc.state.allStations.length),
    );

    bloc.add(const ClearSearch());
    await bloc.stream.firstWhere((s) => !s.isSearching);
    expect(bloc.state.stationResults.length, bloc.state.allStations.length);
    expect(bloc.state.routeResults.length, bloc.state.allRoutes.length);
    await bloc.close();
  });

  testWidgets('search page shows all sections by default and filters by type', (
    tester,
  ) async {
    await tester.runAsync(() => PakRailRepository().loadStations());

    await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
    await tester.pumpAndSettle();

    // Everything is shown by default.
    expect(find.text('ALL STATIONS'), findsOneWidget);
    expect(find.text('ALL ROUTES'), findsOneWidget);
    expect(find.text('ALL TRAINS'), findsOneWidget);

    // Filter to stations only.
    await tester.tap(find.widgetWithText(FilterChip, 'Stations'));
    await tester.pumpAndSettle();

    expect(find.text('ALL STATIONS'), findsOneWidget);
    expect(find.text('ALL ROUTES'), findsNothing);
    expect(find.text('ALL TRAINS'), findsNothing);
    expect(find.byType(TrainCard), findsNothing);

    // The class-filter row is hidden when stations are selected.
    expect(find.widgetWithText(FilterChip, 'Express'), findsNothing);
  });

  testWidgets('mic toggle indicates voice state and fails gracefully', (
    tester,
  ) async {
    await tester.runAsync(() => PakRailRepository().loadStations());

    await tester.pumpWidget(const MaterialApp(home: SearchScreen()));
    await tester.pumpAndSettle();

    // Mic present and off by default.
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    expect(find.textContaining('Listening'), findsNothing);

    // Tap it. In the test environment speech recognition is unavailable, so
    // the app must fall back to the off state with an explanation instead of
    // pretending voice input is active. The platform-channel call only
    // resolves in real async, hence runAsync.
    await tester.runAsync(() async {
      await tester.tap(find.byIcon(Icons.mic_none_rounded));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(
      find.text('Voice input is not available on this device'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    expect(find.textContaining('Listening'), findsNothing);
  });
}
