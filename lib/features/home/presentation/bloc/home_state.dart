part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  /// Upcoming (not yet departed) journeys the user saved from the planner,
  /// sorted by departure time.
  final List<SavedJourney> journeys;

  const HomeLoaded(this.journeys);

  @override
  List<Object> get props => [journeys];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
