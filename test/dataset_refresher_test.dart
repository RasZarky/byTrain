import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:by_train/core/data/pakrail_repository.dart';
import 'package:by_train/core/data/refresh/dataset_refresher.dart';
import 'package:by_train/core/data/refresh/pakrail_importer.dart';

Map<String, dynamic> _dataset() => {
  'meta': {'dataAsOf': '2026-08-13', 'season': 't', 'sources': []},
  'stations': [
    {
      'id': 'test-station',
      'name': 'Test Station',
      'code': 'TST',
      'city': '',
      'province': '',
    },
  ],
  'trains': [],
  'services': [],
};

class _FakeImporter implements PakRailImporter {
  _FakeImporter(this.data);

  final Map<String, dynamic> data;
  bool wasCalled = false;

  @override
  Future<Map<String, dynamic>> buildDataset() async {
    wasCalled = true;
    return data;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('skips refresh when one already succeeded recently', () async {
    SharedPreferences.setMockInitialValues({
      DatasetRefresher.lastRefreshKey: DateTime.now().toIso8601String(),
    });
    final importer = _FakeImporter(_dataset());

    await DatasetRefresher(importer: importer).refreshIfStale();

    expect(importer.wasCalled, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PakRailRepository.refreshedDatasetPrefsKey), isNull);
  });

  test('keeps old data and records the attempt when refresh fails', () async {
    SharedPreferences.setMockInitialValues({});
    // A real transport that always fails: covers offline / blocked sources.
    final importer = PakRailImporter(
      client: MockClient((request) async => http.Response('', 500)),
    );

    await DatasetRefresher(importer: importer).refreshIfStale();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PakRailRepository.refreshedDatasetPrefsKey), isNull);
    expect(prefs.getString(DatasetRefresher.lastAttemptKey), isNotNull);
  });

  test('stores the fresh dataset after a successful refresh', () async {
    SharedPreferences.setMockInitialValues({});
    PakRailRepository.invalidateCache();
    final importer = _FakeImporter(_dataset());

    await DatasetRefresher(importer: importer).refreshIfStale();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(PakRailRepository.refreshedDatasetPrefsKey);
    expect(stored, isNotNull);
    expect((jsonDecode(stored!) as Map)['stations'], isNotEmpty);
    expect(prefs.getString(DatasetRefresher.lastRefreshKey), isNotNull);
    expect(prefs.getString(DatasetRefresher.lastAttemptKey), isNotNull);
  });
}
