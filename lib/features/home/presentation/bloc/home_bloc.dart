import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../train/domain/models/train.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>((event, emit) async {
      emit(HomeLoading());
      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        final trains = [
          const Train(
            id: '101',
            name: 'Express 101',
            number: 'EXP101',
            status: 'On Time',
            departureTime: '10:00 AM',
            arrivalTime: '02:00 PM',
          ),
          const Train(
            id: '202',
            name: 'Local 202',
            number: 'LOC202',
            status: 'Delayed 10m',
            departureTime: '11:30 AM',
            arrivalTime: '01:15 PM',
          ),
          const Train(
            id: '303',
            name: 'Intercity 303',
            number: 'INT303',
            status: 'On Time',
            departureTime: '12:45 PM',
            arrivalTime: '05:30 PM',
          ),
        ];
        
        emit(HomeLoaded(trains));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });
  }
}
