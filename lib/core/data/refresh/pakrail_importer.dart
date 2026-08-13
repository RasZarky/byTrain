// Shared importer: fetches Pakistan Railways timetable data from public
// sources and assembles the dataset map. Used by:
//   1. tool/import_pakrail.dart  — writes assets/data/pakrail.json (CLI)
//   2. DatasetRefresher          — silently refreshes the bundled dataset at
//      app startup (no backend, offline fallback kept)
//
// Sources:
//   1. pakinformation.com/railway-timings/ — per-train stop tables (current season)
//   2. Wikidata SPARQL (property P6785) — official Pakistan Railways station codes
//   3. Wikipedia "List of named passenger trains of Pakistan" — train config
//
// The importer is polite: browser-like User-Agent, retries, and a delay
// between requests. All failures propagate as exceptions — callers decide
// whether to surface them (the app swallows them silently).

import 'dart:convert';

import 'package:http/http.dart' as http;

const String _ua =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/126.0 Safari/537.36';

const String _season = 'Summer timetable 2026 (15 Apr – 14 Oct 2026)';
const List<String> _sources = [
  'https://www.pakinformation.com/railway-timings/',
  'https://www.wikidata.org/wiki/Property:P6785',
  'https://en.wikipedia.org/wiki/List_of_named_passenger_trains_of_Pakistan',
];

/// Train config: slug on pakinformation, name, UP/DN numbers (per Wikipedia),
/// class, and days of operation.
class TrainCfg {
  final String slug;
  final String name;
  final String upNumber;
  final String dnNumber;
  final String type; // express | passenger | shuttle
  final String days;
  const TrainCfg(
    this.slug,
    this.name,
    this.upNumber,
    this.dnNumber,
    this.type,
    this.days,
  );
}

const List<TrainCfg> _trains = [
  TrainCfg(
    'karakoram-express',
    'Karakoram Express',
    '41UP',
    '42DN',
    'express',
    'Daily',
  ),
  TrainCfg('tezgam', 'Tezgam', '7UP', '8DN', 'express', 'Daily'),
  TrainCfg('green-line', 'Green Line', '5UP', '6DN', 'express', 'Daily'),
  TrainCfg('khyber-mail', 'Khyber Mail', '1UP', '2DN', 'express', 'Daily'),
  TrainCfg(
    'pak-business-express',
    'Pak Business Express',
    '33UP',
    '34DN',
    'express',
    'Daily',
  ),
  TrainCfg(
    'rawal-express',
    'Rawal Express',
    '105UP',
    '106DN',
    'express',
    'Daily',
  ),
  TrainCfg(
    'jaffar-express',
    'Jaffar Express',
    '39UP',
    '40DN',
    'express',
    'Daily',
  ),
  TrainCfg(
    'pakistan-express',
    'Pakistan Express',
    '45UP',
    '46DN',
    'express',
    'Daily',
  ),
  TrainCfg(
    'hazara-express',
    'Hazara Express',
    '11UP',
    '12DN',
    'express',
    'Daily',
  ),
  TrainCfg(
    'shalimar-express',
    'Shalimar Express',
    '27UP',
    '28DN',
    'express',
    'Daily',
  ),
  TrainCfg(
    'faiz-ahmed-faiz-passenger',
    'Faiz Ahmed Faiz Passenger',
    '209UP',
    '210DN',
    'passenger',
    'Daily',
  ),
  TrainCfg(
    'jand-passenger',
    'Jand Passenger',
    '203UP',
    '204DN',
    'passenger',
    'Daily',
  ),
  TrainCfg('subak-khram', 'Subak Kharam', '103UP', '104DN', 'express', 'Daily'),
];

/// Curated metadata for stations expected in this import (city/province).
/// Codes come from Wikidata (fetched below); unknown codes stay empty.
const Map<String, List<String>> _stationMeta = {
  'karachi cantt': ['Karachi', 'Sindh'],
  'karachi city': ['Karachi', 'Sindh'],
  'hyderabad jn': ['Hyderabad', 'Sindh'],
  'nawabshah': ['Nawabshah', 'Sindh'],
  'rohri jn': ['Rohri', 'Sindh'],
  'sukkur': ['Sukkur', 'Sindh'],
  'shikarpur': ['Shikarpur', 'Sindh'],
  'jacobabad': ['Jacobabad', 'Sindh'],
  'kotri': ['Kotri', 'Sindh'],
  'larkana': ['Larkana', 'Sindh'],
  'bahawalpur': ['Bahawalpur', 'Punjab'],
  'khanewal': ['Khanewal', 'Punjab'],
  'multan cantt': ['Multan', 'Punjab'],
  'toba tek singh': ['Toba Tek Singh', 'Punjab'],
  'faisalabad': ['Faisalabad', 'Punjab'],
  'lahore jn': ['Lahore', 'Punjab'],
  'gujranwala': ['Gujranwala', 'Punjab'],
  'wazirabad jn': ['Wazirabad', 'Punjab'],
  'rawalpindi': ['Rawalpindi', 'Punjab'],
  'jhelum': ['Jhelum', 'Punjab'],
  'lala musa jn': ['Lala Musa', 'Punjab'],
  'sargodha': ['Sargodha', 'Punjab'],
  'peshawar cantt': ['Peshawar', 'Khyber Pakhtunkhwa'],
  'peshawar city': ['Peshawar', 'Khyber Pakhtunkhwa'],
  'nowshera': ['Nowshera', 'Khyber Pakhtunkhwa'],
  'margalla': ['Islamabad', 'Islamabad Capital Territory'],
  'golra sharif': ['Islamabad', 'Islamabad Capital Territory'],
  'quetta': ['Quetta', 'Balochistan'],
  'sibi': ['Sibi', 'Balochistan'],
  'mach': ['Mach', 'Balochistan'],
  'dadu': ['Dadu', 'Sindh'],
  'landhi': ['Karachi', 'Sindh'],
  'drigh road': ['Karachi', 'Sindh'],
  'kot addu': ['Kot Addu', 'Punjab'],
  'dera ghazi khan': ['Dera Ghazi Khan', 'Punjab'],
  'dera ismail khan': ['Dera Ismail Khan', 'Khyber Pakhtunkhwa'],
  'kundian': ['Kundian', 'Punjab'],
  'mithankot': ['Mithankot', 'Punjab'],
  'okara': ['Okara', 'Punjab'],
  'sahiwal': ['Sahiwal', 'Punjab'],
  'chichawatni': ['Chichawatni', 'Punjab'],
  'kamoke': ['Kamoke', 'Punjab'],
  'gujrat': ['Gujrat', 'Punjab'],
  'chaklala': ['Rawalpindi', 'Punjab'],
  'taxila': ['Taxila', 'Punjab'],
  'attock city jn': ['Attock', 'Punjab'],
  'havelian': ['Havelian', 'Khyber Pakhtunkhwa'],
  'narowal jn': ['Narowal', 'Punjab'],
  'jand jn': ['Jand', 'Punjab'],
  'kundian jn': ['Kundian', 'Punjab'],
  'sangjani': ['Islamabad', 'Islamabad Capital Territory'],
  'nur jn': ['Islamabad', 'Islamabad Capital Territory'],
};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _clean(String s) {
  s = s
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&#160;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');
  s = s.replaceAll(RegExp(r'<[^>]+>'), ' ');
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

List<String> _cells(String rowHtml) {
  final cells = RegExp(r'<t[dh][\s\S]*?</t[dh]>', caseSensitive: false)
      .allMatches(rowHtml)
      .map((m) => _clean(m.group(0)!))
      .where((c) => c.isNotEmpty)
      .toList();
  return cells;
}

List<String> _tables(String html) {
  return RegExp(
    r'<table[\s\S]*?</table>',
    caseSensitive: false,
  ).allMatches(html).map((m) => m.group(0)!).toList();
}

bool _isHeaderRow(List<String> cells) {
  if (cells.isEmpty) return false;
  final joined = cells.join(' ').toLowerCase();
  return joined.contains('stop') &&
      (joined.contains('arrival') || joined.contains('departure'));
}

/// Parses "03:00 P.M" (or "15:00") into minutes past midnight; null if not a time.
/// Tolerates stray whitespace such as "09 :35 P.M".
int? _minutes(String raw) {
  final m = RegExp(
    r'(\d{1,2})\s*:\s*(\d{2})\s*([AP])\.?\s*M\.?',
    caseSensitive: false,
  ).firstMatch(raw);
  if (m != null) {
    var h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final ap = m.group(3)!.toUpperCase();
    if (ap == 'P' && h != 12) h += 12;
    if (ap == 'A' && h == 12) h = 0;
    return h * 60 + min;
  }
  final m24 = RegExp(r'(\d{1,2})\s*:\s*(\d{2})').firstMatch(raw);
  if (m24 != null) {
    return int.parse(m24.group(1)!) * 60 + int.parse(m24.group(2)!);
  }
  return null;
}

bool _isPlaceholder(String s) {
  return s.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').isEmpty;
}

String _fmt(int minutes) {
  final h = (minutes ~/ 60) % 24;
  final m = minutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

/// Alias map: page spellings -> canonical station key.
const Map<String, String> _alias = {
  'chak lala': 'chaklala',
  't.t singh': 'toba tek singh',
  'toba tek singh': 'toba tek singh',
  'lala musa': 'lala musa jn',
  'samasata': 'samasata jn',
  'shahdara': 'shahdara bagh jn',
  'margala': 'margalla',
};

/// Canonical identity key for a station name (used to merge across trains).
/// Normalizes Cant/Cantt/Cantonment -> cantt and Jn/Junction -> jn so the same
/// station spelled differently on different pages merges into one id.
String _canonKey(String name) {
  var s = _clean(name).toLowerCase();
  s = s.replaceAll(RegExp(r'\bcantt?\b|\bcantonment\b'), 'cantt');
  s = s.replaceAll(RegExp(r'\bjn\b|\bjunction\b'), 'jn');
  s = _alias[s] ?? s;
  s = s.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

/// Nice display name for a station id.
String _displayName(String id) {
  final words = id
      .split(' ')
      .map((w) {
        if (w.isEmpty) return w;
        return w[0].toUpperCase() + w.substring(1);
      })
      .join(' ');
  return words.replaceAll(' Jn', ' Junction').replaceAll(' Cantt', ' Cantt');
}

// ---------------------------------------------------------------------------
// HTTP fetching
// ---------------------------------------------------------------------------

Future<String> _fetch(http.Client client, String url) async {
  for (var attempt = 0; attempt < 2; attempt++) {
    try {
      final res = await client
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent': _ua,
              'Accept': 'text/html,application/xhtml+xml',
              'Accept-Language': 'en-US,en;q=0.9',
            },
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200 && !res.body.contains('Not Acceptable')) {
        return res.body;
      }
    } catch (_) {
      // Network error, timeout, or non-200: retry below.
    }
    await Future<void>.delayed(const Duration(seconds: 3));
  }
  throw Exception('Failed to fetch $url after retries');
}

Future<Map<String, String>> _fetchWikidataCodes(http.Client client) async {
  const query = '''
SELECT ?station ?label ?code WHERE {
  ?station wdt:P6785 ?code .
  OPTIONAL { ?station rdfs:label ?label . FILTER(LANG(?label) = "en") }
} LIMIT 5000''';
  final url = Uri.https('query.wikidata.org', '/sparql', {
    'query': query,
    'format': 'json',
  });
  final res = await client
      .get(
        url,
        headers: {
          'User-Agent': 'bytrain-import/0.1 (data research)',
          'Accept': 'application/sparql-results+json',
        },
      )
      .timeout(const Duration(seconds: 30));
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  final map = <String, String>{};
  for (final b
      in (json['results'] as Map<String, dynamic>)['bindings'] as List) {
    final code = (b as Map<String, dynamic>)['code']?['value'] as String?;
    final label = b['label']?['value'] as String?;
    if (code == null || label == null) continue;
    var key = _canonKey(
      label.replaceAll(
        RegExp(r' (railway )?station$', caseSensitive: false),
        '',
      ),
    );
    map.putIfAbsent(key, () => code);
  }
  return map;
}

// ---------------------------------------------------------------------------
// Timetable parsing
// ---------------------------------------------------------------------------

class ParsedStop {
  final String stationName;
  final String stationId;
  final String arrival; // HH:mm
  final String departure; // HH:mm
  final int dayOffset;
  ParsedStop(
    this.stationName,
    this.stationId,
    this.arrival,
    this.departure,
    this.dayOffset,
  );
}

class ParsedService {
  final String id;
  final String trainId;
  final String number;
  final String direction;
  final String originId;
  final String destinationId;
  final String departureTime;
  final String arrivalTime;
  final int durationMin;
  final List<ParsedStop> stops;
  ParsedService(
    this.id,
    this.trainId,
    this.number,
    this.direction,
    this.originId,
    this.destinationId,
    this.departureTime,
    this.arrivalTime,
    this.durationMin,
    this.stops,
  );
}

/// Parses the two timetable tables (UP, then DN) out of a train page.
List<ParsedService> _parseServices(String html, TrainCfg cfg, int expected) {
  final tables = _tables(html).where((t) {
    final rows = RegExp(
      r'<tr[\s\S]*?</tr>',
      caseSensitive: false,
    ).allMatches(t).toList();
    return rows.isNotEmpty && _isHeaderRow(_cells(rows.first.group(0)!));
  }).toList();

  final services = <ParsedService>[];
  for (var i = 0; i < tables.length && i < 2; i++) {
    final number = i == 0 ? cfg.upNumber : cfg.dnNumber;
    final direction = i == 0 ? 'UP' : 'DN';
    final rows = RegExp(
      r'<tr[\s\S]*?</tr>',
      caseSensitive: false,
    ).allMatches(tables[i]).map((m) => m.group(0)!).toList();

    final stops = <({String name, int? arr, int? dep})>[];
    for (final row in rows) {
      final cells = _cells(row);
      if (_isHeaderRow(cells) || cells.length < 3) continue;
      final name = cells[0];
      if (name.isEmpty) continue;
      final arrRaw = cells[1];
      final depRaw = cells[2];
      final isStart = arrRaw.toLowerCase().contains('start');
      final isEnd = depRaw.toLowerCase().contains('end');
      int? arr = isStart ? _minutes(depRaw) : _minutes(arrRaw);
      int? dep = isEnd ? _minutes(arrRaw) : _minutes(depRaw);
      // Some pages use "----" for the origin/destination rows instead of
      // Start/End markers: the missing time equals the present one.
      if (arr == null && dep != null && _isPlaceholder(arrRaw)) arr = dep;
      if (dep == null && arr != null && _isPlaceholder(depRaw)) dep = arr;
      if (arr == null || dep == null) continue;
      stops.add((name: name, arr: arr, dep: dep));
    }
    if (stops.length < 2) {
      continue;
    }

    // Assign day offsets across midnight.
    var day = 0;
    int? prevDep;
    final parsed = <ParsedStop>[];
    for (final s in stops) {
      if (prevDep != null && s.arr! < prevDep) day++;
      parsed.add(
        ParsedStop(s.name, _canonKey(s.name), _fmt(s.arr!), _fmt(s.dep!), day),
      );
      prevDep = s.dep;
    }

    final first = parsed.first;
    final last = parsed.last;
    final duration =
        (last.dayOffset * 1440 + _stopMinutes(last.arrival)) -
        _stopMinutes(first.departure);

    services.add(
      ParsedService(
        number,
        cfg.slug,
        number,
        direction,
        first.stationId,
        last.stationId,
        first.departure,
        last.arrival,
        duration,
        parsed,
      ),
    );
  }
  return services;
}

int _stopMinutes(String hhmm) {
  final t = hhmm.split(':');
  return int.parse(t[0]) * 60 + int.parse(t[1]);
}

// ---------------------------------------------------------------------------
// Dataset assembly
// ---------------------------------------------------------------------------

/// Fetches the current timetable from the public sources and assembles the
/// dataset map (same shape as `assets/data/pakrail.json`). Throws on any
/// failure; callers decide how to handle it.
class PakRailImporter {
  PakRailImporter({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> buildDataset() async {
    final wdCodes = await _fetchWikidataCodes(_client);

    final stations = <String, Map<String, dynamic>>{};
    final trainRows = <Map<String, dynamic>>[];
    final serviceRows = <Map<String, dynamic>>[];

    void addStation(String id, String displayName, String code) {
      if (stations.containsKey(id)) return;
      final meta = _stationMeta[id];
      stations[id] = {
        'id': id,
        'name': _displayName(id),
        'code': code,
        'city': meta?[0] ?? '',
        'province': meta?[1] ?? '',
      };
    }

    try {
      for (final cfg in _trains) {
        final url =
            'https://www.pakinformation.com/railway-timings/${cfg.slug}.html';
        final html = await _fetch(_client, url);

        final services = _parseServices(html, cfg, 2);
        for (final s in services) {
          trainRows.add({
            'id': cfg.slug,
            'name': cfg.name,
            'type': cfg.type,
            'days': cfg.days,
            'imageUrl': null,
          });
          final stopsJson = <Map<String, dynamic>>[];
          for (final stop in s.stops) {
            addStation(
              stop.stationId,
              stop.stationName,
              wdCodes[stop.stationId] ?? '',
            );
            stopsJson.add({
              'stationId': stop.stationId,
              'stationName': _displayName(stop.stationId),
              'arrivalTime': stop.arrival,
              'departureTime': stop.departure,
              'dayOffset': stop.dayOffset,
              'platform': null,
            });
          }
          serviceRows.add({
            'id': s.id,
            'trainId': cfg.slug,
            'number': s.number,
            'direction': s.direction,
            'originStationId': s.originId,
            'destinationStationId': s.destinationId,
            'departureTime': s.departureTime,
            'arrivalTime': s.arrivalTime,
            'durationMin': s.durationMin,
            'stops': stopsJson,
          });
        }
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    } finally {
      _client.close();
    }

    // De-dupe trains (multiple services share a train row).
    final seenTrains = <String>{};
    final uniqueTrains = trainRows
        .where((t) => seenTrains.add(t['id'] as String))
        .toList();

    return {
      'meta': {
        'dataAsOf': DateTime.now().toIso8601String().substring(0, 10),
        'season': _season,
        'sources': _sources,
        'trainCount': uniqueTrains.length,
        'serviceCount': serviceRows.length,
        'stationCount': stations.length,
      },
      'stations': stations.values.toList(),
      'trains': uniqueTrains,
      'services': serviceRows,
    };
  }
}
