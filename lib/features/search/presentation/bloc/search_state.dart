part of 'search_bloc.dart';

class SearchState extends Equatable {
  final List<Train> allTrains;
  final List<Train> filteredTrains;
  final String searchQuery;
  final String selectedFilter;
  final Train? selectedTrain;
  final bool isSearching;
  final bool locationPermissionGranted;
  final MapType mapType;
  final bool isLoading;
  final String? errorMessage;

  const SearchState({
    this.allTrains = const [],
    this.filteredTrains = const [],
    this.searchQuery = '',
    this.selectedFilter = 'All',
    this.selectedTrain,
    this.isSearching = false,
    this.locationPermissionGranted = false,
    this.mapType = MapType.normal,
    this.isLoading = false,
    this.errorMessage,
  });

  SearchState copyWith({
    List<Train>? allTrains,
    List<Train>? filteredTrains,
    String? searchQuery,
    String? selectedFilter,
    Train? Function()? selectedTrain,
    bool? isSearching,
    bool? locationPermissionGranted,
    MapType? mapType,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return SearchState(
      allTrains: allTrains ?? this.allTrains,
      filteredTrains: filteredTrains ?? this.filteredTrains,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedTrain: selectedTrain != null ? selectedTrain() : this.selectedTrain,
      isSearching: isSearching ?? this.isSearching,
      locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
      mapType: mapType ?? this.mapType,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        allTrains,
        filteredTrains,
        searchQuery,
        selectedFilter,
        selectedTrain,
        isSearching,
        locationPermissionGranted,
        mapType,
        isLoading,
        errorMessage,
      ];
}
