import 'package:equatable/equatable.dart';
import '../../../station/domain/models/station.dart';

abstract class JourneyPlannerEvent extends Equatable {
  const JourneyPlannerEvent();

  @override
  List<Object?> get props => [];
}

class FromStationSelected extends JourneyPlannerEvent {
  final Station? station;
  const FromStationSelected(this.station);

  @override
  List<Object?> get props => [station];
}

class ToStationSelected extends JourneyPlannerEvent {
  final Station? station;
  const ToStationSelected(this.station);

  @override
  List<Object?> get props => [station];
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
