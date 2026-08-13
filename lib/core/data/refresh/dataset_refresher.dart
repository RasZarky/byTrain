import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../pakrail_repository.dart';
import 'pakrail_importer.dart';

/// Refreshes the bundled timetable in the background at app startup, without
/// any user-visible UI.
///
/// - Runs at most once per [refreshInterval] (successful refreshes) and
///   respects a shorter [retryInterval] after failures, so offline starts or
///   a blocked source never hammer the public sites.
/// - A fresh dataset is stored in shared_preferences; [PakRailRepository]
///   prefers it but always falls back to the bundled asset, so the app keeps
///   working fully offline even if a refresh never succeeds.
/// - Every failure is swallowed: the user should never notice any of this.
class DatasetRefresher {
  DatasetRefresher({PakRailImporter? importer})
    : _importer = importer ?? PakRailImporter();

  final PakRailImporter _importer;

  static const Duration refreshInterval = Duration(hours: 24);
  static const Duration retryInterval = Duration(hours: 1);

  static const String lastRefreshKey = 'pakrail_last_refresh';
  static const String lastAttemptKey = 'pakrail_last_attempt';

  /// Attempts a silent refresh if one is due. Never throws.
  Future<void> refreshIfStale() async {
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      return; // No persistence available — keep the bundled dataset.
    }

    final lastRefresh = DateTime.tryParse(
      prefs.getString(lastRefreshKey) ?? '',
    );
    if (lastRefresh != null &&
        DateTime.now().difference(lastRefresh) < refreshInterval) {
      return;
    }
    final lastAttempt = DateTime.tryParse(
      prefs.getString(lastAttemptKey) ?? '',
    );
    if (lastAttempt != null &&
        DateTime.now().difference(lastAttempt) < retryInterval) {
      return;
    }

    try {
      final data = await _importer.buildDataset();
      await prefs.setString(
        PakRailRepository.refreshedDatasetPrefsKey,
        jsonEncode(data),
      );
      await prefs.setString(lastRefreshKey, DateTime.now().toIso8601String());
      // Let in-app loads pick up the new dataset.
      PakRailRepository.invalidateCache();
    } catch (_) {
      // Offline, blocked source, or parse failure: the old (bundled or
      // previously refreshed) dataset stays in place. Nothing to tell the user.
    } finally {
      try {
        await prefs.setString(lastAttemptKey, DateTime.now().toIso8601String());
      } catch (_) {
        // Ignore persistence hiccups.
      }
    }
  }
}
