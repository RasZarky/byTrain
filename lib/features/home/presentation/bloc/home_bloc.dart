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
          ),
        ];
        
        emit(HomeLoaded(trains));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });
  }
}
