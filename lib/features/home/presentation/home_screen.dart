import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../train/domain/models/train.dart';
import 'bloc/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ByTrain Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final bool isLoading = state is HomeLoading;
          
          final List<Train> trains = state is HomeLoaded 
              ? state.recentTrains 
              : List.generate(3, (index) => const Train(
                  id: 'loading',
                  name: 'Loading Train Name',
                  number: '...',
                  status: '...',
                  departureTime: '...',
                  arrivalTime: '...',
                ));

          return Skeletonizer(
            enabled: isLoading,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ElevatedButton(
                  onPressed: () => context.push('/search'),
                  child: const Text('Search Trains'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => context.push('/journey-planner'),
                  child: const Text('Journey Planner'),
                ),
                const SizedBox(height: 20),
                const Text('Recent Trains', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 10),
                ...trains.map((train) => ListTile(
                  title: Text(train.name),
                  subtitle: const Text('Check status'),
                  leading: const Icon(Icons.train),
                  onTap: isLoading ? null : () => context.push('/train-details/${train.id}'),
                )).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
