import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/saved_journeys_store.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/quick_action_card.dart';
import '../../journey_planner/domain/models/saved_journey.dart';
import 'bloc/home_bloc.dart';
import 'widgets/saved_journey_card.dart';

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

              return RefreshIndicator(
                edgeOffset: 380,
                onRefresh: () async {
                  context.read<HomeBloc>().add(LoadHomeData());
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 380)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSectionHeader(
                          theme,
                          'Upcoming Journeys',
                          (state is HomeLoaded && state.journeys.isNotEmpty)
                              ? () => context.push('/journey-planner')
                              : null,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppDimensions.s),
                    ),
                    if (isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state is HomeLoaded && state.journeys.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyJourneysState(),
                      )
                    else if (state is HomeLoaded)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final journey = state.journeys[index];
                            return SavedJourneyCard(
                              journey: journey,
                              onTap: () => context.push(
                                '/train-details/${journey.trainId}',
                              ),
                              onRemove: () => _removeJourney(context, journey),
                            );
                          }, childCount: state.journeys.length),
                        ),
                      )
                    else if (state is HomeError)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            state.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
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

  Future<void> _removeJourney(
    BuildContext context,
    SavedJourney journey,
  ) async {
    await SavedJourneysStore().remove(journey);
    if (context.mounted) {
      context.read<HomeBloc>().add(LoadHomeData());
    }
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
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Travel with comfort",
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Explore Your Next\nJourney",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
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

  Widget _buildSectionHeader(
    ThemeData theme,
    String title,
    VoidCallback? onAction,
  ) {
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
              'Plan New',
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

class _EmptyJourneysState extends StatelessWidget {
  const _EmptyJourneysState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 44,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.l),
          Text(
            'No upcoming journeys yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.s),
          Text(
            'Plan a route in the Journey Planner and save it — upcoming\nsaved journeys will appear here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.l),
          FilledButton.icon(
            onPressed: () => context.push('/journey-planner'),
            icon: const Icon(Icons.route_rounded, size: 18),
            label: const Text('Plan a Journey'),
          ),
        ],
      ),
    );
  }
}
