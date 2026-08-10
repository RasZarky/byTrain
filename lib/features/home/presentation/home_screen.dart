import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/quick_action_card.dart';
import '../../train/domain/models/train.dart';
import '../../train/presentation/widgets/train_card.dart';
import 'bloc/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final bool isLoading = state is HomeLoading;
              
              final List<Train> trains = state is HomeLoaded 
                  ? state.recentTrains 
                  : List.generate(3, (index) => const Train(
                      id: 'loading',
                      name: 'Loading Train Name',
                      number: '0000',
                      status: 'On Time',
                      departureTime: '00:00',
                      arrivalTime: '00:00',
                    ));

              return RefreshIndicator(
                edgeOffset: 380,
                onRefresh: () async {
                  context.read<HomeBloc>().add(LoadHomeData());
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 380),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              theme, 
                              'Recent Journeys', 
                              () => context.push('/recent-journeys'),
                            ),
                            const SizedBox(height: AppDimensions.s),
                          ],
                        ),
                      ),
                    ),
                    Skeletonizer.sliver(
                      enabled: isLoading,
                      child: SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final train = trains[index];
                              return TrainCard(
                                train: train,
                                isLoading: isLoading,
                                onTap: () => context.push(
                                  '/train-details/${train.id}',
                                  extra: train,
                                ),
                              );
                            },
                            childCount: trains.length,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 280,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -80,
                bottom: 20,
                child: Icon(
                  Icons.train_rounded,
                  size: 280,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Travel with comfort",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Explore Your Next\nJourney",
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -80,
          left: 20,
          right: 20,
          child: _buildBookingCard(context, theme),
        ),
      ],
    );
  }

  Widget _buildBookingCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: QuickActionCard(
              label: 'Route Planner',
              icon: Icons.route_rounded,
              color: theme.colorScheme.primary,
              onTap: () => context.push('/journey-planner'),
            ),
          ),
          const SizedBox(width: AppDimensions.m),
          Expanded(
            child: QuickActionCard(
              label: 'Search',
              icon: Icons.search,
              color: Colors.teal.shade700,
              onTap: () => context.push('/search'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, VoidCallback? onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        if (onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              'See All',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
