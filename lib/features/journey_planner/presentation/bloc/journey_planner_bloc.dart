import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/journey.dart';
import '../../../station/domain/models/station.dart';
import '../../../train/domain/models/train.dart';
import 'journey_planner_event.dart';
import 'journey_planner_state.dart';

class JourneyPlannerBloc extends Bloc<JourneyPlannerEvent, JourneyPlannerState> {
  JourneyPlannerBloc() : super(JourneyPlannerState(selectedDateTime: DateTime.now())) {
    on<FromStationChanged>(_onFromStationChanged);
    on<ToStationChanged>(_onToStationChanged);
    on<DateTimeChanged>(_onDateTimeChanged);
    on<StationsSwapped>(_onStationsSwapped);
    on<SearchStarted>(_onSearchStarted);
    on<DirectOnlyToggled>(_onDirectOnlyToggled);
    on<FastestRouteToggled>(_onFastestRouteToggled);
    on<CheapestFirstToggled>(_onCheapestFirstToggled);
    on<RecentSearchSelected>(_onRecentSearchSelected);
    on<RecentSearchesCleared>(_onRecentSearchesCleared);
  }

  void _onFromStationChanged(FromStationChanged event, Emitter<JourneyPlannerState> emit) {
    emit(state.copyWith(fromStation: event.fromStation, status: JourneyPlannerStatus.initial));
  }

  void _onToStationChanged(ToStationChanged event, Emitter<JourneyPlannerState> emit) {
    emit(state.copyWith(toStation: event.toStation, status: JourneyPlannerStatus.initial));
  }

  void _onDateTimeChanged(DateTimeChanged event, Emitter<JourneyPlannerState> emit) {
    emit(state.copyWith(selectedDateTime: event.dateTime));
  }

  void _onStationsSwapped(StationsSwapped event, Emitter<JourneyPlannerState> emit) {
    emit(state.copyWith(
      fromStation: state.toStation,
      toStation: state.fromStation,
      swapTurns: state.swapTurns + 0.5,
    ));
  }

  Future<void> _onSearchStarted(SearchStarted event, Emitter<JourneyPlannerState> emit) async {
    if (state.fromStation.isEmpty || state.toStation.isEmpty) {
      emit(state.copyWith(
        status: JourneyPlannerStatus.failure,
        errorMessage: 'Please enter both departure and destination stations',
      ));
      return;
    }

    emit(state.copyWith(status: JourneyPlannerStatus.loading));

    // Simulate search API call
    await Future.delayed(const Duration(milliseconds: 1500));

    final journeys = _getMockJourneys(
      state.fromStation,
      state.toStation,
      state.fastestRoute,
      state.cheapestFirst,
      state.directOnly,
    );

    emit(state.copyWith(
      status: JourneyPlannerStatus.success,
      journeys: journeys,
    ));
  }

  void _onDirectOnlyToggled(DirectOnlyToggled event, Emitter<JourneyPlannerState> emit) {
    emit(state.copyWith(directOnly: !state.directOnly));
    if (state.status == JourneyPlannerStatus.success) {
      add(const SearchStarted());
    }
  }

  void _onFastestRouteToggled(FastestRouteToggled event, Emitter<JourneyPlannerState> emit) {
    final newValue = !state.fastestRoute;
    emit(state.copyWith(
      fastestRoute: newValue,
      cheapestFirst: newValue ? false : state.cheapestFirst,
    ));
    if (state.status == JourneyPlannerStatus.success) {
      add(const SearchStarted());
    }
  }

  void _onCheapestFirstToggled(CheapestFirstToggled event, Emitter<JourneyPlannerState> emit) {
    final newValue = !state.cheapestFirst;
    emit(state.copyWith(
      cheapestFirst: newValue,
      fastestRoute: newValue ? false : state.fastestRoute,
    ));
    if (state.status == JourneyPlannerStatus.success) {
      add(const SearchStarted());
    }
  }

  void _onRecentSearchSelected(RecentSearchSelected event, Emitter<JourneyPlannerState> emit) {
    emit(state.copyWith(
      fromStation: event.from,
      toStation: event.to,
      status: JourneyPlannerStatus.initial,
    ));
    add(const SearchStarted());
  }

  void _onRecentSearchesCleared(RecentSearchesCleared event, Emitter<JourneyPlannerState> emit) {
    emit(state.copyWith(recentSearches: const []));
  }

  List<Journey> _getMockJourneys(
    String from,
    String to,
    bool fastest,
    bool cheapest,
    bool directOnly,
  ) {
    final fromStation = Station(id: '1', name: from, code: from.substring(0, 3).toUpperCase());
    final toStation = Station(id: '2', name: to, code: to.substring(0, 3).toUpperCase());

    final journeys = [
      Journey(
        from: fromStation,
        to: toStation,
        train: Train(
          id: 'T1',
          name: 'Pakistan Railways',
          number: '101',
          status: 'On Time',
          departureTime: '10:15',
          arrivalTime: '14:32',
        ),
        departureTime: DateTime.now().copyWith(hour: 10, minute: 15),
        arrivalTime: DateTime.now().copyWith(hour: 14, minute: 32),
        price: cheapest ? 2500 : 4200,
      ),
      if (!directOnly)
        Journey(
          from: fromStation,
          to: toStation,
          train: Train(
            id: 'T2',
            name: 'Green Line',
            number: '102',
            status: 'Delayed',
            departureTime: '10:45',
            arrivalTime: '15:50',
          ),
          departureTime: DateTime.now().copyWith(hour: 10, minute: 45),
          arrivalTime: DateTime.now().copyWith(hour: 15, minute: 50),
          price: cheapest ? 1800 : 2800,
        ),
      Journey(
        from: fromStation,
        to: toStation,
        train: Train(
          id: 'T3',
          name: 'Tezgam',
          number: '103',
          status: 'On Time',
          departureTime: '11:15',
          arrivalTime: '15:45',
        ),
        departureTime: DateTime.now().copyWith(hour: 11, minute: 15),
        arrivalTime: DateTime.now().copyWith(hour: 15, minute: 45),
        price: 3500,
      ),
    ];

    return journeys;
  }
}
