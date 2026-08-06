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
            id: '202',
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
            id: '303',
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
        ];
        
        emit(HomeLoaded(trains));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });
  }
}
