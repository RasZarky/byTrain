import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/data/saved_journeys_store.dart';
import '../../../../features/journey_planner/domain/models/saved_journey.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({SavedJourneysStore? savedJourneysStore})
    : _savedJourneysStore = savedJourneysStore ?? SavedJourneysStore(),
      super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  final SavedJourneysStore _savedJourneysStore;

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final now = DateTime.now();
      final journeys = await _savedJourneysStore.load();
      final upcoming = [
        for (final j in journeys)
          if (j.departureTime.isAfter(now)) j,
      ]..sort((a, b) => a.departureTime.compareTo(b.departureTime));
      emit(HomeLoaded(upcoming));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
