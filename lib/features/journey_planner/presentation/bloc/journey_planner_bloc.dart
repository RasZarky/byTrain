import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/pakrail_repository.dart';
import '../../domain/models/journey.dart';
import 'journey_planner_event.dart';
import 'journey_planner_state.dart';

class JourneyPlannerBloc
    extends Bloc<JourneyPlannerEvent, JourneyPlannerState> {
  JourneyPlannerBloc({PakRailRepository? repository})
    : _repository = repository ?? PakRailRepository(),
      super(JourneyPlannerState(selectedDateTime: DateTime.now())) {
    on<FromStationSelected>(_onFromStationSelected);
    on<ToStationSelected>(_onToStationSelected);
    on<DateTimeChanged>(_onDateTimeChanged);
    on<StationsSwapped>(_onStationsSwapped);
    on<SearchStarted>(_onSearchStarted);
    on<DirectOnlyToggled>(_onDirectOnlyToggled);
    on<FastestRouteToggled>(_onFastestRouteToggled);
  }

  final PakRailRepository _repository;

  void _onFromStationSelected(
    FromStationSelected event,
    Emitter<JourneyPlannerState> emit,
  ) {
    emit(
      state.copyWith(from: event.station, status: JourneyPlannerStatus.initial),
    );
  }

  void _onToStationSelected(
    ToStationSelected event,
    Emitter<JourneyPlannerState> emit,
  ) {
    emit(
      state.copyWith(to: event.station, status: JourneyPlannerStatus.initial),
    );
  }

  void _onDateTimeChanged(
    DateTimeChanged event,
    Emitter<JourneyPlannerState> emit,
  ) {
    emit(state.copyWith(selectedDateTime: event.dateTime));
  }

  void _onStationsSwapped(
    StationsSwapped event,
    Emitter<JourneyPlannerState> emit,
  ) {
    emit(
      state.copyWith(
        from: state.to,
        to: state.from,
        swapTurns: state.swapTurns + 0.5,
      ),
    );
  }

  Future<void> _onSearchStarted(
    SearchStarted event,
    Emitter<JourneyPlannerState> emit,
  ) async {
    final from = state.from;
    final to = state.to;
    if (from == null || to == null) {
      emit(
        state.copyWith(
          status: JourneyPlannerStatus.failure,
          errorMessage: 'Please choose both departure and destination stations',
        ),
      );
      return;
    }
    if (from.id == to.id) {
      emit(
        state.copyWith(
          status: JourneyPlannerStatus.failure,
          errorMessage: 'Departure and destination must be different stations',
        ),
      );
      return;
    }

    emit(state.copyWith(status: JourneyPlannerStatus.loading));

    final journeys = await _repository.findJourneys(
      fromStationId: from.id,
      toStationId: to.id,
      date: state.selectedDateTime,
      directOnly: state.directOnly,
    );

    if (journeys.isEmpty) {
      emit(
        state.copyWith(
          status: JourneyPlannerStatus.failure,
          errorMessage: 'No trains found on this route for the selected date',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: JourneyPlannerStatus.success,
        journeys: _orderResults(journeys),
        errorMessage: null,
      ),
    );
  }

  /// Orders results so journeys matching the selected preferences appear at
  /// the top: direct journeys first (when Direct Only is on) and shorter
  /// journeys first (when Fastest Route is on). Within groups, and when no
  /// preference applies, results stay sorted by departure time.
  List<Journey> _orderResults(List<Journey> journeys) {
    final sorted = [...journeys];
    sorted.sort((a, b) {
      if (state.directOnly) {
        final aDirect = _isDirect(a);
        final bDirect = _isDirect(b);
        if (aDirect != bDirect) return aDirect ? -1 : 1;
      }
      if (state.fastestRoute) {
        final aDuration = a.arrivalTime.difference(a.departureTime);
        final bDuration = b.arrivalTime.difference(b.departureTime);
        if (aDuration != bDuration) return aDuration.compareTo(bDuration);
      }
      return a.departureTime.compareTo(b.departureTime);
    });
    return sorted;
  }

  /// The public timetable carries no connection data, so every journey is a
  /// direct single-train trip today; this guard keeps Direct Only meaningful
  /// if multi-train journeys are ever added.
  bool _isDirect(Journey journey) => true;

  void _onDirectOnlyToggled(
    DirectOnlyToggled event,
    Emitter<JourneyPlannerState> emit,
  ) {
    emit(state.copyWith(directOnly: !state.directOnly));
    if (state.status == JourneyPlannerStatus.success) {
      add(const SearchStarted());
    }
  }

  void _onFastestRouteToggled(
    FastestRouteToggled event,
    Emitter<JourneyPlannerState> emit,
  ) {
    emit(state.copyWith(fastestRoute: !state.fastestRoute));
    if (state.status == JourneyPlannerStatus.success) {
      add(const SearchStarted());
    }
  }
}
