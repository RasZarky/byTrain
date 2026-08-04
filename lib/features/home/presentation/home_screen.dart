import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/widgets/custom_card.dart';
import '../../train/domain/models/train.dart';
import 'bloc/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ByTrain'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(LoadHomeData());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Trains', 
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...trains.map((train) => CustomCard(
                    onTap: isLoading ? null : () => context.push('/train-details/${train.id}'),
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(
                        train.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        'Status: ${train.status}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.train_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            label: 'Search',
            icon: Icons.search,
            onPressed: () => context.push('/search'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            label: 'Plan',
            icon: Icons.map_outlined,
            onPressed: () => context.push('/journey-planner'),
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      onTap: onPressed,
      child: Column(
        children: [
          Icon(icon, size: 32, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
