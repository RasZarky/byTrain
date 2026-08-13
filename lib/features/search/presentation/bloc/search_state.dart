part of 'search_bloc.dart';

class SearchState extends Equatable {
  final List<Train> allTrains;
  final List<Train> filteredTrains;
  final List<Station> allStations;
  final List<Station> stationResults;
  final List<Journey> allRoutes;
  final List<Journey> routeResults;
  final String searchQuery;
  final String selectedFilter;
  final String contentFilter;
  final Train? selectedTrain;
  final bool isSearching;
  final bool isLoading;
  final String? errorMessage;

  const SearchState({
    this.allTrains = const [],
    this.filteredTrains = const [],
    this.allStations = const [],
    this.stationResults = const [],
    this.allRoutes = const [],
    this.routeResults = const [],
    this.searchQuery = '',
    this.selectedFilter = 'All',
    this.contentFilter = 'All',
    this.selectedTrain,
    this.isSearching = false,
    this.isLoading = false,
    this.errorMessage,
  });

  SearchState copyWith({
    List<Train>? allTrains,
    List<Train>? filteredTrains,
    List<Station>? allStations,
    List<Station>? stationResults,
    List<Journey>? allRoutes,
    List<Journey>? routeResults,
    String? searchQuery,
    String? selectedFilter,
    String? contentFilter,
    Train? Function()? selectedTrain,
    bool? isSearching,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return SearchState(
      allTrains: allTrains ?? this.allTrains,
      filteredTrains: filteredTrains ?? this.filteredTrains,
      allStations: allStations ?? this.allStations,
      stationResults: stationResults ?? this.stationResults,
      allRoutes: allRoutes ?? this.allRoutes,
      routeResults: routeResults ?? this.routeResults,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      contentFilter: contentFilter ?? this.contentFilter,
      selectedTrain: selectedTrain != null
          ? selectedTrain()
          : this.selectedTrain,
      isSearching: isSearching ?? this.isSearching,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    allTrains,
    filteredTrains,
    allStations,
    stationResults,
    allRoutes,
    routeResults,
    searchQuery,
    selectedFilter,
    contentFilter,
    selectedTrain,
    isSearching,
    isLoading,
    errorMessage,
  ];
}
