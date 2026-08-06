part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrains extends SearchEvent {}

class UpdateSearchQuery extends SearchEvent {
  final String query;
  const UpdateSearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectFilter extends SearchEvent {
  final String filter;
  const SelectFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SelectTrain extends SearchEvent {
  final Train? train;
  const SelectTrain(this.train);

  @override
  List<Object?> get props => [train];
}

class UpdateLocationPermission extends SearchEvent {
  final bool granted;
  const UpdateLocationPermission(this.granted);

  @override
  List<Object?> get props => [granted];
}

class CycleMapType extends SearchEvent {}

class ClearSearch extends SearchEvent {}
