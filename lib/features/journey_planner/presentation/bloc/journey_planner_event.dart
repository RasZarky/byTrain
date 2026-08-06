import 'package:equatable/equatable.dart';

abstract class JourneyPlannerEvent extends Equatable {
  const JourneyPlannerEvent();

  @override
  List<Object?> get props => [];
}

class FromStationChanged extends JourneyPlannerEvent {
  final String fromStation;
  const FromStationChanged(this.fromStation);

  @override
  List<Object?> get props => [fromStation];
}

class ToStationChanged extends JourneyPlannerEvent {
  final String toStation;
  const ToStationChanged(this.toStation);

  @override
  List<Object?> get props => [toStation];
}

class DateTimeChanged extends JourneyPlannerEvent {
  final DateTime dateTime;
  const DateTimeChanged(this.dateTime);

  @override
  List<Object?> get props => [dateTime];
}

class StationsSwapped extends JourneyPlannerEvent {
  const StationsSwapped();
}

class SearchStarted extends JourneyPlannerEvent {
  const SearchStarted();
}

class DirectOnlyToggled extends JourneyPlannerEvent {
  const DirectOnlyToggled();
}

class FastestRouteToggled extends JourneyPlannerEvent {
  const FastestRouteToggled();
}

class CheapestFirstToggled extends JourneyPlannerEvent {
  const CheapestFirstToggled();
}

class RecentSearchSelected extends JourneyPlannerEvent {
  final String from;
  final String to;
  const RecentSearchSelected(this.from, this.to);

  @override
  List<Object?> get props => [from, to];
}

class RecentSearchesCleared extends JourneyPlannerEvent {
  const RecentSearchesCleared();
}
