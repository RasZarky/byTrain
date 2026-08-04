import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../train/domain/models/train.dart';

// Events
abstract class SearchEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchTrains extends SearchEvent {
  final String query;
  SearchTrains(this.query);
  @override
  List<Object> get props => [query];
}

// States
abstract class SearchState extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}
class SearchLoading extends SearchState {}
class SearchLoaded extends SearchState {
  final List<Train> results;
  SearchLoaded(this.results);
  @override
  List<Object> get props => [results];
}
class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchTrains>((event, emit) async {
      if (event.query.isEmpty) return;
      
      emit(SearchLoading());
      try {
        await Future.delayed(const Duration(seconds: 1));
        // Mock results
        final results = [
          Train(id: '101', name: 'Express 101', number: event.query, status: 'On Time', departureTime: '10:00 AM', arrivalTime: '2:00 PM'),
          const Train(id: '102', name: 'Express 102', number: 'EXP102', status: 'On Time', departureTime: '11:00 AM', arrivalTime: '3:00 PM'),
        ];
        emit(SearchLoaded(results));
      } catch (e) {
        emit(SearchError('Failed to find trains'));
      }
    });
  }
}
