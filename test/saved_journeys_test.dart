import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:by_train/core/data/saved_journeys_store.dart';
import 'package:by_train/features/home/presentation/bloc/home_bloc.dart';
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

  test('store saves, dedupes and removes journeys', () async {
    final store = SavedJourneysStore();
    final journey = _journey(DateTime(2026, 8, 20, 15));

    expect(await store.load(), isEmpty);
    expect(await store.add(journey), isTrue);
    // Identical train + departure is a duplicate.
    expect(await store.add(journey), isFalse);
    expect((await store.load()).length, 1);

    await store.remove(journey);
    expect(await store.load(), isEmpty);
  });

  test('HomeBloc keeps only upcoming journeys, sorted by departure', () async {
    final store = SavedJourneysStore();
    await store.add(_journey(DateTime.now().subtract(const Duration(days: 1))));
    await store.add(
      _journey(DateTime.now().add(const Duration(days: 3)), trainId: '5UP'),
    );
    await store.add(
      _journey(DateTime.now().add(const Duration(days: 1)), trainId: '41UP'),
    );

    final bloc = HomeBloc(savedJourneysStore: store);
    final states = expectLater(
      bloc.stream,
      emitsInOrder([isA<HomeLoading>(), isA<HomeLoaded>()]),
    );
    bloc.add(LoadHomeData());
    await states;

    final loaded = bloc.state as HomeLoaded;
    expect(loaded.journeys.length, 2);
    expect(loaded.journeys.first.trainId, '41UP'); // departs sooner
    expect(loaded.journeys.last.trainId, '5UP');
  });
}
