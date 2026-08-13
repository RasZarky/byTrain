// Import tool: fetches Pakistan Railways timetable data from public sources
// and writes it to assets/data/pakrail.json (bundled with the app — no
// backend). The fetch/parse logic lives in
// lib/core/data/refresh/pakrail_importer.dart, shared with the app's silent
// background refresh so both stay in sync.
//
// Usage (from repo root):
//   dart run tool/import_pakrail.dart [output-path]
//
// The importer is polite: browser-like User-Agent, retries, and a delay
// between requests.

import 'dart:convert';
import 'dart:io';

import 'package:by_train/core/data/refresh/pakrail_importer.dart';

void main(List<String> args) async {
  final outPath = args.isNotEmpty ? args.first : 'assets/data/pakrail.json';
  final data = await PakRailImporter().buildDataset();
  final file = File(outPath);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  final meta = data['meta'] as Map<String, dynamic>;
  stdout.writeln('Wrote $outPath');
  stdout.writeln(
    '  dataAsOf=${meta['dataAsOf']} trains=${meta['trainCount']} '
    'services=${meta['serviceCount']} stations=${meta['stationCount']}',
  );
}
