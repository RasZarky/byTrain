import 'package:equatable/equatable.dart';
import '../../../station/domain/models/station.dart';
import '../../domain/models/journey.dart';

enum JourneyPlannerStatus { initial, loading, success, failure }

class JourneyPlannerState extends Equatable {
  final Station? from;
  final Station? to;
  final DateTime selectedDateTime;
  final double swapTurns;
  final bool directOnly;
  final bool fastestRoute;
  final List<Journey> journeys;
  final JourneyPlannerStatus status;
  final String? errorMessage;

  const JourneyPlannerState({
    this.from,
    this.to,
    required this.selectedDateTime,
    this.swapTurns = 0.0,
    this.directOnly = false,
    this.fastestRoute = true,
    this.journeys = const [],
    this.status = JourneyPlannerStatus.initial,
    this.errorMessage,
  });

  JourneyPlannerState copyWith({
    Station? from,
    Station? to,
    DateTime? selectedDateTime,
    double? swapTurns,
    bool? directOnly,
    bool? fastestRoute,
    List<Journey>? journeys,
    JourneyPlannerStatus? status,
    String? errorMessage,
  }) {
    return JourneyPlannerState(
      from: from ?? this.from,
      to: to ?? this.to,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
      swapTurns: swapTurns ?? this.swapTurns,
      directOnly: directOnly ?? this.directOnly,
      fastestRoute: fastestRoute ?? this.fastestRoute,
      journeys: journeys ?? this.journeys,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    from,
    to,
    selectedDateTime,
    swapTurns,
    directOnly,
    fastestRoute,
    journeys,
    status,
    errorMessage,
  ];
}
