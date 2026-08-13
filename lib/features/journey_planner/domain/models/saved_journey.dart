import 'package:equatable/equatable.dart';

import 'journey.dart';

/// A journey the user saved from the Journey Planner, kept as a flat record so
/// it can be persisted (shared_preferences) and shown on the Home page.
class SavedJourney extends Equatable {
  final String trainId;
  final String trainNumber;
  final String trainName;
  final String fromStationId;
  final String fromName;
  final String fromCode;
  final String toStationId;
  final String toName;
  final String toCode;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double? price;
  final DateTime savedAt;

  const SavedJourney({
    required this.trainId,
    required this.trainNumber,
    required this.trainName,
    required this.fromStationId,
    required this.fromName,
    required this.fromCode,
    required this.toStationId,
    required this.toName,
    required this.toCode,
    required this.departureTime,
    required this.arrivalTime,
    this.price,
    required this.savedAt,
  });

  /// Stable identity used for store dedupe and saved-state checks
  /// (same train + departure time).
  static String keyFor(String trainId, DateTime departureTime) =>
      '$trainId|${departureTime.toIso8601String()}';

  String get key => keyFor(trainId, departureTime);

  factory SavedJourney.fromJourney(Journey journey) {
    return SavedJourney(
      trainId: journey.train.id,
      trainNumber: journey.train.number,
      trainName: journey.train.name,
      fromStationId: journey.from.id,
      fromName: journey.from.name,
      fromCode: journey.from.code,
      toStationId: journey.to.id,
      toName: journey.to.name,
      toCode: journey.to.code,
      departureTime: journey.departureTime,
      arrivalTime: journey.arrivalTime,
      price: journey.price,
      savedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'trainId': trainId,
    'trainNumber': trainNumber,
    'trainName': trainName,
    'fromStationId': fromStationId,
    'fromName': fromName,
    'fromCode': fromCode,
    'toStationId': toStationId,
    'toName': toName,
    'toCode': toCode,
    'departureTime': departureTime.toIso8601String(),
    'arrivalTime': arrivalTime.toIso8601String(),
    'price': price,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedJourney.fromJson(Map<String, dynamic> json) {
    return SavedJourney(
      trainId: json['trainId'] as String,
      trainNumber: json['trainNumber'] as String,
      trainName: json['trainName'] as String,
      fromStationId: json['fromStationId'] as String,
      fromName: json['fromName'] as String,
      fromCode: (json['fromCode'] as String?) ?? '',
      toStationId: json['toStationId'] as String,
      toName: json['toName'] as String,
      toCode: (json['toCode'] as String?) ?? '',
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      price: (json['price'] as num?)?.toDouble(),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    trainId,
    trainNumber,
    trainName,
    fromStationId,
    fromName,
    fromCode,
    toStationId,
    toName,
    toCode,
    departureTime,
    arrivalTime,
    price,
    savedAt,
  ];
}
