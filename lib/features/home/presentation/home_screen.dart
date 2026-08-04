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
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
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

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(LoadHomeData());
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: size.height * 0.5,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  stretch: true,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/train1.png',
                          fit: BoxFit.cover,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                                theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
                                theme.scaffoldBackgroundColor,
                              ],
                              stops: const [0.0, 0.8, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                    titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    centerTitle: false,
                    title: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'ByTrain',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildGreeting(theme),
                      const SizedBox(height: AppDimensions.s),
                      Skeletonizer(
                        enabled: isLoading,
                        child: _buildQuickActions(context, theme),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Journeys',
                            style: theme.textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.s),
                      Skeletonizer(
                        enabled: isLoading,
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: trains.length,
                          itemBuilder: (context, index) {
                            final train = trains[index];
                            return TrainCard(
                              train: train,
                              isLoading: isLoading,
                              onTap: () => context.push('/train-details/${train.id}'),
                            );
                          },
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreeting(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        Text(
          'Where to today?',
          style: theme.textTheme.headlineLarge,
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning,';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon,';
    } else if (hour >= 17 && hour < 21) {
      return 'Good evening,';
    } else {
      return 'Good night,';
    }
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: QuickActionCard(
            label: 'Search',
            icon: Icons.search_rounded,
            color: theme.colorScheme.primary,
            onTap: () => context.go('/search'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: QuickActionCard(
            label: 'Planner',
            icon: Icons.route_rounded,
            color: theme.colorScheme.secondary,
            onTap: () => context.go('/journey-planner'),
          ),
        ),
      ],
    );
  }
}
