import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:by_train/core/data/pakrail_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled dataset loads with metadata', () async {
    final repo = PakRailRepository();
    final meta = await repo.meta();
    expect(meta.dataAsOf, isNotEmpty);
    expect(meta.season, isNotEmpty);
    expect(meta.sources, isNotEmpty);
  });

  test('all services map to Train objects', () async {
    final repo = PakRailRepository();
    final trains = await repo.loadAllTrains();
    expect(trains.length, greaterThanOrEqualTo(20));
    for (final t in trains) {
      expect(t.id, isNotEmpty);
      expect(t.number, isNotEmpty);
      expect(t.name, isNotEmpty);
      expect(t.departureTime, matches(RegExp(r'^\d{2}:\d{2}$')));
      expect(t.arrivalTime, matches(RegExp(r'^\d{2}:\d{2}$')));
      expect(t.stops.length, greaterThanOrEqualTo(2));
    }
  });

  test('Karakoram Express 41UP has the real route and stops', () async {
    final repo = PakRailRepository();
    final trains = await repo.loadAllTrains();
    final karakoram = trains.firstWhere((t) => t.number == '41UP');
    expect(karakoram.name, 'Karakoram Express');
    expect(karakoram.stops.first.stationName, contains('Karachi'));
    expect(karakoram.stops.last.stationName, contains('Lahore'));
    expect(karakoram.stops.length, greaterThanOrEqualTo(8));
    // Route is via Faisalabad, not Multan.
    final via = karakoram.stops.map((s) => s.stationName).join(', ');
    expect(via, contains('Faisalabad'));
    expect(via, isNot(contains('Multan')));
  });

  test('stations include official Pakistan Railways codes', () async {
    final repo = PakRailRepository();
    final stations = await repo.loadStations();
    final lhr = stations.firstWhere((s) => s.name.contains('Lahore'));
    expect(lhr.code, 'LHR');
    expect(stations.any((s) => s.code == 'ROH'), isTrue);
  });

  test('popular trains power the home screen row', () async {
    final repo = PakRailRepository();
    final popular = await repo.popularTrains();
    expect(popular, isNotEmpty);
    expect(popular.first.name, 'Karakoram Express');
  });

  test('journey search finds real direct trains between stations', () async {
    final repo = PakRailRepository();
    final lahore = (await repo.stationByName('Lahore Junction'))!;
    final karachi = (await repo.stationByName('Karachi Cantt'))!;

    final journeys = await repo.findJourneys(
      fromStationId: lahore.id,
      toStationId: karachi.id,
      date: DateTime(2026, 8, 15),
    );
    expect(journeys, isNotEmpty);
    for (final j in journeys) {
      expect(j.from.id, lahore.id);
      expect(j.to.id, karachi.id);
      expect(j.arrivalTime.isAfter(j.departureTime), isTrue);
      // Fares are not published in the public timetable.
      expect(j.price, isNull);
    }
    // Sorted by departure time.
    for (var i = 1; i < journeys.length; i++) {
      expect(
        journeys[i].departureTime.isBefore(journeys[i - 1].departureTime),
        isFalse,
      );
    }
  });

  test('each direction matches its own UP/DN service', () async {
    final repo = PakRailRepository();
    final lahore = (await repo.stationByName('Lahore Junction'))!;
    final karachi = (await repo.stationByName('Karachi Cantt'))!;
    final down = await repo.findJourneys(
      fromStationId: lahore.id,
      toStationId: karachi.id,
      date: DateTime(2026, 8, 15),
    );
    final up = await repo.findJourneys(
      fromStationId: karachi.id,
      toStationId: lahore.id,
      date: DateTime(2026, 8, 15),
    );
    // 42DN runs Lahore->Karachi, 41UP runs Karachi->Lahore.
    expect(down.any((j) => j.train.number == '42DN'), isTrue);
    expect(up.any((j) => j.train.number == '41UP'), isTrue);
  });

  test('station queries return real metadata', () async {
    final repo = PakRailRepository();
    final stations = await repo.loadStations();
    expect(stations, isNotEmpty);

    final lhr = await repo.stationById('lahore jn');
    expect(lhr, isNotNull);
    expect(lhr!.name, 'Lahore Junction');
    expect(lhr.code, 'LHR');
    expect(lhr.city, 'Lahore');
    expect(lhr.province, 'Punjab');

    final through = await repo.trainsThroughStation('karachi cantt');
    expect(through.length, greaterThanOrEqualTo(5));
  });

  test('station search matches names and codes', () async {
    final repo = PakRailRepository();
    final byName = await repo.searchStations('Multan');
    expect(byName, isNotEmpty);
    expect(byName.any((s) => s.name.contains('Multan')), isTrue);

    final byCode = await repo.searchStations('LHR');
    expect(byCode.any((s) => s.code == 'LHR'), isTrue);

    final empty = await repo.searchStations('zzz-no-such-station');
    expect(empty, isEmpty);
  });

  test('route search resolves "X to Y" queries to real journeys', () async {
    final repo = PakRailRepository();
    final journeys = await repo.findRoutesForQuery('Lahore to Karachi');
    expect(journeys, isNotEmpty);
    expect(journeys.any((j) => j.train.number == '42DN'), isTrue);

    final arrow = await repo.findRoutesForQuery('Karachi → Lahore');
    expect(arrow.any((j) => j.train.number == '41UP'), isTrue);

    final none = await repo.findRoutesForQuery('Lahore to nowhere-ville');
    expect(none, isEmpty);
  });

  test('allJourneys returns every service as a route', () async {
    final repo = PakRailRepository();
    final routes = await repo.allJourneys(date: DateTime(2026, 8, 15));
    expect(routes.length, greaterThanOrEqualTo(20));
    for (final j in routes) {
      expect(j.from.id, isNot(j.to.id));
      expect(j.arrivalTime.isAfter(j.departureTime), isTrue);
    }
    // Sorted by departure time.
    for (var i = 1; i < routes.length; i++) {
      expect(
        routes[i].departureTime.isBefore(routes[i - 1].departureTime),
        isFalse,
      );
    }
  });

  test('searchRoutes matches corridors and plain substrings', () async {
    final repo = PakRailRepository();
    final corridor = await repo.searchRoutes('Lahore to Karachi');
    expect(corridor.any((j) => j.train.number == '42DN'), isTrue);

    final byName = await repo.searchRoutes('Karakoram');
    expect(byName, isNotEmpty);
    expect(byName.every((j) => j.train.name.contains('Karakoram')), isTrue);

    final byStation = await repo.searchRoutes('Multan');
    expect(
      byStation.every(
        (j) => j.from.name.contains('Multan') || j.to.name.contains('Multan'),
      ),
      isTrue,
    );

    final none = await repo.searchRoutes('zzz-no-such-route');
    expect(none, isEmpty);
  });

  test('repository prefers a refreshed dataset when one is stored', () async {
    PakRailRepository.invalidateCache();
    SharedPreferences.setMockInitialValues({
      PakRailRepository.refreshedDatasetPrefsKey: jsonEncode({
        'meta': {'dataAsOf': '2026-08-13', 'season': 't', 'sources': []},
        'stations': [
          {
            'id': 'test-station',
            'name': 'Test Station',
            'code': 'TST',
            'city': 'Test City',
            'province': 'Test Province',
          },
        ],
        'trains': [],
        'services': [],
      }),
    });

    final repo = PakRailRepository();
    final stations = await repo.loadStations();
    expect(stations.length, 1);
    expect(stations.single.name, 'Test Station');
    expect(stations.single.code, 'TST');
  });

  test(
    'repository falls back to the bundled asset without a refresh',
    () async {
      PakRailRepository.invalidateCache();
      SharedPreferences.setMockInitialValues({});

      final repo = PakRailRepository();
      final stations = await repo.loadStations();
      expect(stations.length, greaterThanOrEqualTo(100));
    },
  );
}
