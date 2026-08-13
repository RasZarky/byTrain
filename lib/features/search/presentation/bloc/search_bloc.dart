import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/data/pakrail_repository.dart';
import '../../../journey_planner/domain/models/journey.dart';
import '../../../station/domain/models/station.dart';
import '../../../train/domain/models/train.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({PakRailRepository? repository})
    : _repository = repository ?? PakRailRepository(),
      super(const SearchState()) {
    on<LoadTrains>(_onLoadTrains);
    on<UpdateSearchQuery>(_onUpdateSearchQuery);
    on<SelectFilter>(_onSelectFilter);
    on<SelectContentFilter>(_onSelectContentFilter);
    on<SelectTrain>(_onSelectTrain);
    on<ClearSearch>(_onClearSearch);
  }

  final PakRailRepository _repository;

  Future<void> _onLoadTrains(
    LoadTrains event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final trains = await _repository.loadAllTrains();
      final stations = await _repository.loadStations();
      final routes = await _repository.allJourneys();
      emit(
        state.copyWith(
          allTrains: trains,
          filteredTrains: trains,
          allStations: stations,
          stationResults: stations,
          allRoutes: routes,
          routeResults: routes,
          isLoading: false,
          errorMessage: () => null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: () => 'Failed to load data: $e',
        ),
      );
    }
  }

  Future<void> _onUpdateSearchQuery(
    UpdateSearchQuery event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query;
    final isSearching = query.isNotEmpty;
    final stations = isSearching
        ? await _repository.searchStations(query)
        : state.allStations;
    final routes = isSearching
        ? await _repository.searchRoutes(query)
        : state.allRoutes;
    final filtered = _filter(state.allTrains, query, state.selectedFilter);
    emit(
      state.copyWith(
        searchQuery: query,
        isSearching: isSearching,
        stationResults: stations,
        routeResults: routes,
        filteredTrains: filtered,
      ),
    );
  }

  void _onSelectFilter(SelectFilter event, Emitter<SearchState> emit) {
    final filtered = _filter(state.allTrains, state.searchQuery, event.filter);
    emit(
      state.copyWith(selectedFilter: event.filter, filteredTrains: filtered),
    );
  }

  void _onSelectContentFilter(
    SelectContentFilter event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(contentFilter: event.filter));
  }

  void _onSelectTrain(SelectTrain event, Emitter<SearchState> emit) {
    emit(
      state.copyWith(
        selectedTrain: () => event.train,
        searchQuery: event.train != null
            ? event.train!.name
            : state.searchQuery,
        isSearching: event.train != null ? true : state.isSearching,
      ),
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    final filtered = _filter(state.allTrains, '', state.selectedFilter);
    emit(
      state.copyWith(
        searchQuery: '',
        isSearching: false,
        selectedTrain: () => null,
        stationResults: state.allStations,
        routeResults: state.allRoutes,
        filteredTrains: filtered,
      ),
    );
  }

  List<Train> _filter(List<Train> trains, String query, String filter) {
    final lowerQuery = query.toLowerCase();
    return trains.where((train) {
      final matchesQuery =
          train.name.toLowerCase().contains(lowerQuery) ||
          train.number.toLowerCase().contains(lowerQuery);

      bool matchesFilter = true;
      if (filter == 'Express') {
        matchesFilter = train.type == TrainType.express;
      } else if (filter == 'Regional') {
        matchesFilter = train.type == TrainType.regional;
      } else if (filter == 'Local') {
        matchesFilter = train.type == TrainType.local;
      }

      return matchesQuery && matchesFilter;
    }).toList();
  }
}
