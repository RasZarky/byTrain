import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../train/domain/models/train.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  static final List<Train> _mockTrains = [
    const Train(
      id: '1',
      name: 'Karakoram Express',
      number: '41UP',
      status: 'On Time',
      departureTime: '15:30',
      arrivalTime: '10:00',
      type: TrainType.express,
      imageUrl: 'https://images.unsplash.com/photo-1532105956626-9569c03602f6?auto=format&fit=crop&w=800&q=80',
      stops: [
        TrainStop(stationName: 'Karachi Cantt', arrivalTime: '03:30 PM', status: StopStatus.passed, platform: '1'),
        TrainStop(stationName: 'Hyderabad', arrivalTime: '05:45 PM', status: StopStatus.passed, platform: '2'),
        TrainStop(stationName: 'Rohri', arrivalTime: '10:15 PM', status: StopStatus.passed, platform: '3'),
        TrainStop(stationName: 'Bahawalpur', arrivalTime: '02:30 AM', status: StopStatus.current, platform: '1'),
        TrainStop(stationName: 'Multan Cantt', arrivalTime: '04:20 AM', status: StopStatus.upcoming, platform: '2'),
        TrainStop(stationName: 'Lahore Junction', arrivalTime: '10:00 AM', status: StopStatus.upcoming, platform: '4'),
      ],
    ),
    const Train(
      id: '2',
      name: 'Tezgam',
      number: '7UP',
      status: 'Delayed 15m',
      departureTime: '08:00',
      arrivalTime: '13:15',
      type: TrainType.express,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQne0B6q_11OAY3_pFEIyBCarKCFUdz9ZgDdU-Uy3iOxA&s=10',
      stops: [
        TrainStop(stationName: 'Karachi Cantt', arrivalTime: '08:00 AM', status: StopStatus.passed, platform: '2'),
        TrainStop(stationName: 'Hyderabad', arrivalTime: '10:20 AM', status: StopStatus.passed, platform: '1'),
        TrainStop(stationName: 'Nawabshah', arrivalTime: '12:45 PM', status: StopStatus.current, platform: '3', delay: '+15m'),
        TrainStop(stationName: 'Rohri', arrivalTime: '03:30 PM', status: StopStatus.upcoming, platform: '2'),
        TrainStop(stationName: 'Lahore Junction', arrivalTime: '01:15 PM', status: StopStatus.upcoming, platform: '1'),
      ],
    ),
    const Train(
      id: '3',
      name: 'Green Line',
      number: '5UP',
      status: 'On Time',
      departureTime: '22:00',
      arrivalTime: '20:30',
      type: TrainType.express,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRvVGdkFWOA6lbDYZsj_Lw1jZnMMJwWcWyHbZgzH1EXA&s=10',
      stops: [
        TrainStop(stationName: 'Islamabad', arrivalTime: '10:00 PM', status: StopStatus.passed, platform: '1'),
        TrainStop(stationName: 'Rawalpindi', arrivalTime: '10:30 PM', status: StopStatus.current, platform: '2'),
        TrainStop(stationName: 'Lahore', arrivalTime: '02:30 AM', status: StopStatus.upcoming, platform: '3'),
        TrainStop(stationName: 'Karachi', arrivalTime: '08:30 PM', status: StopStatus.upcoming, platform: '1'),
      ],    ),
    const Train(
      id: '4',
      name: 'Lahore Passenger',
      number: '212DN',
      status: 'On Time',
      departureTime: '11:00',
      arrivalTime: '14:30',
      type: TrainType.regional,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNpkFukdpqJfYnIuwazNU1ZKaeFfx-JaGjoEwsWBEi2w&s=10',
      stops: [
        TrainStop(stationName: 'Lahore', arrivalTime: '11:00 AM', status: StopStatus.passed, platform: '4'),
        TrainStop(stationName: 'Raiwind', arrivalTime: '11:45 AM', status: StopStatus.current, platform: '1'),
        TrainStop(stationName: 'Okara', arrivalTime: '01:15 PM', status: StopStatus.upcoming, platform: '2'),
        TrainStop(stationName: 'Sahiwal', arrivalTime: '02:30 PM', status: StopStatus.upcoming, platform: '3'),
      ],
    ),
    const Train(
      id: '5',
      name: 'Babu Passenger',
      number: '208DN',
      status: 'Delayed 45m',
      departureTime: '16:00',
      arrivalTime: '18:15',
      type: TrainType.regional,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ3IKoFeU8G9OZxiqD1ZpcE2ojTRRCtXl9sZNqgseqVAA&s=10',
      stops: [
        TrainStop(stationName: 'Lahore', arrivalTime: '04:00 PM', status: StopStatus.passed, platform: '5'),
        TrainStop(stationName: 'Guiranwala', arrivalTime: '05:00 PM', status: StopStatus.current, platform: '2', delay: '+45m'),
        TrainStop(stationName: 'Wazirabad', arrivalTime: '06:15 PM', status: StopStatus.upcoming, platform: '3'),
      ],
    ),
  ];

  SearchBloc() : super(const SearchState()) {
    on<LoadTrains>((event, emit) {
      emit(state.copyWith(isLoading: true));
      final filtered = _filter(_mockTrains, state.searchQuery, state.selectedFilter);
      emit(state.copyWith(
        allTrains: _mockTrains,
        filteredTrains: filtered,
        isLoading: false,
      ));
    });

    on<UpdateSearchQuery>((event, emit) {
      final isSearching = event.query.isNotEmpty;
      final filtered = _filter(state.allTrains, event.query, state.selectedFilter);
      emit(state.copyWith(
        searchQuery: event.query,
        isSearching: isSearching,
        filteredTrains: filtered,
      ));
    });

    on<SelectFilter>((event, emit) {
      final filtered = _filter(state.allTrains, state.searchQuery, event.filter);
      emit(state.copyWith(
        selectedFilter: event.filter,
        filteredTrains: filtered,
      ));
    });

    on<SelectTrain>((event, emit) {
      emit(state.copyWith(
        selectedTrain: () => event.train,
        searchQuery: event.train != null ? event.train!.name : state.searchQuery,
        isSearching: event.train != null ? true : state.isSearching,
      ));
    });

    on<ClearSearch>((event, emit) {
      final filtered = _filter(state.allTrains, '', state.selectedFilter);
      emit(state.copyWith(
        searchQuery: '',
        isSearching: false,
        selectedTrain: () => null,
        filteredTrains: filtered,
      ));
    });
  }

  List<Train> _filter(List<Train> trains, String query, String filter) {
    final lowerQuery = query.toLowerCase();
    return trains.where((train) {
      final matchesQuery = train.name.toLowerCase().contains(lowerQuery) || 
                          train.number.toLowerCase().contains(lowerQuery);
      
      bool matchesFilter = true;
      if (filter == 'Express') {
        matchesFilter = train.type == TrainType.express;
      } else if (filter == 'Regional') {
        matchesFilter = train.type == TrainType.regional;
      } else if (filter == 'Delayed') {
        matchesFilter = train.status.toLowerCase().contains('delayed');
      }

      return matchesQuery && matchesFilter;
    }).toList();
  }
}
