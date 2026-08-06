import 'package:equatable/equatable.dart';
import '../../domain/models/journey.dart';

enum JourneyPlannerStatus { initial, loading, success, failure }

class JourneyPlannerState extends Equatable {
  final String fromStation;
  final String toStation;
  final DateTime selectedDateTime;
  final double swapTurns;
  final bool directOnly;
  final bool fastestRoute;
  final bool cheapestFirst;
  final List<Journey> journeys;
  final JourneyPlannerStatus status;
  final String? errorMessage;
  final List<Map<String, String>> recentSearches;

  const JourneyPlannerState({
    this.fromStation = 'Lahore Junction',
    this.toStation = 'Karachi Cantt',
    required this.selectedDateTime,
    this.swapTurns = 0.0,
    this.directOnly = false,
    this.fastestRoute = true,
    this.cheapestFirst = false,
    this.journeys = const [],
    this.status = JourneyPlannerStatus.initial,
    this.errorMessage,
    this.recentSearches = const [
      {'from': 'Lahore Junction', 'to': 'Rawalpindi'},
      {'from': 'Karachi Cantt', 'to': 'Multan Cantt'},
      {'from': 'Faisalabad', 'to': 'Lahore Junction'},
    ],
  });

  JourneyPlannerState copyWith({
    String? fromStation,
    String? toStation,
    DateTime? selectedDateTime,
    double? swapTurns,
    bool? directOnly,
    bool? fastestRoute,
    bool? cheapestFirst,
    List<Journey>? journeys,
    JourneyPlannerStatus? status,
    String? errorMessage,
    List<Map<String, String>>? recentSearches,
  }) {
    return JourneyPlannerState(
      fromStation: fromStation ?? this.fromStation,
      toStation: toStation ?? this.toStation,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
      swapTurns: swapTurns ?? this.swapTurns,
      directOnly: directOnly ?? this.directOnly,
      fastestRoute: fastestRoute ?? this.fastestRoute,
      cheapestFirst: cheapestFirst ?? this.cheapestFirst,
      journeys: journeys ?? this.journeys,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  @override
  List<Object?> get props => [
        fromStation,
        toStation,
        selectedDateTime,
        swapTurns,
        directOnly,
        fastestRoute,
        cheapestFirst,
        journeys,
        status,
        errorMessage,
        recentSearches,
      ];
}
