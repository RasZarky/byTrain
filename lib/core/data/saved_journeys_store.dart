import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/journey_planner/domain/models/saved_journey.dart';

/// Persists journeys the user saved from the Journey Planner so they can be
/// shown on the Home page (upcoming only).
class SavedJourneysStore {
  static const String _key = 'saved_journeys';

  Future<List<SavedJourney>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return [
        for (final item in list)
          SavedJourney.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      // Corrupt or outdated data: treat as empty rather than crashing.
      return const [];
    }
  }

  /// Adds a journey unless an identical one (same train + departure) already
  /// exists. Returns true if a new journey was stored.
  Future<bool> add(SavedJourney journey) async {
    final all = await load();
    final exists = all.any(
      (j) =>
          j.trainId == journey.trainId &&
          j.departureTime == journey.departureTime,
    );
    if (exists) return false;
    await _save([...all, journey]);
    return true;
  }

  Future<void> remove(SavedJourney journey) async {
    final all = await load();
    await _save([
      for (final j in all)
        if (!(j.trainId == journey.trainId &&
            j.departureTime == journey.departureTime))
          j,
    ]);
  }

  Future<void> _save(List<SavedJourney> journeys) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final j in journeys) j.toJson()]),
    );
  }
}
