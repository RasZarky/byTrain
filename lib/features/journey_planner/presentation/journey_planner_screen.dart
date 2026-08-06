import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_dimensions.dart';
import 'bloc/journey_planner_bloc.dart';
import 'bloc/journey_planner_event.dart';
import 'bloc/journey_planner_state.dart';
import 'widgets/preferences_section.dart';
import 'widgets/recent_searches_section.dart';
import 'widgets/results_section.dart';
import 'widgets/route_selection_card.dart';
import 'widgets/searching_loader.dart';

class JourneyPlannerScreen extends StatelessWidget {
  const JourneyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JourneyPlannerBloc(),
      child: const JourneyPlannerView(),
    );
  }
}

class JourneyPlannerView extends StatefulWidget {
  const JourneyPlannerView({super.key});

  @override
  State<JourneyPlannerView> createState() => _JourneyPlannerViewState();
}

class _JourneyPlannerViewState extends State<JourneyPlannerView> with TickerProviderStateMixin {
  late final TextEditingController _fromController;
  late final TextEditingController _toController;
  
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();

  late final AnimationController _resultsFadeController;
  late final Animation<double> _resultsFadeAnimation;
  late final Animation<double> _resultsSlideAnimation;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<JourneyPlannerBloc>();
    _fromController = TextEditingController(text: bloc.state.fromStation);
    _toController = TextEditingController(text: bloc.state.toStation);

    _resultsFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _resultsFadeAnimation = CurvedAnimation(
      parent: _resultsFadeController,
      curve: Curves.easeIn,
    );
    _resultsSlideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _resultsFadeController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    _resultsFadeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, DateTime currentDateTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDateTime),
      );

      if (pickedTime != null) {
        if (mounted) {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          context.read<JourneyPlannerBloc>().add(DateTimeChanged(newDateTime));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<JourneyPlannerBloc, JourneyPlannerState>(
      listener: (context, state) {
        if (state.status == JourneyPlannerStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
        
        // Keep controllers in sync with BLoC state (e.g. after swap or recent search select)
        if (_fromController.text != state.fromStation) {
          _fromController.text = state.fromStation;
        }
        if (_toController.text != state.toStation) {
          _toController.text = state.toStation;
        }

        if (state.status == JourneyPlannerStatus.success) {
          _resultsFadeController.forward(from: 0.0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 120,
          centerTitle: false,
          titleSpacing: AppDimensions.m,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Where are we heading?',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Plan your next train adventure effortlessly.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<JourneyPlannerBloc, JourneyPlannerState>(
          builder: (context, state) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.m,
                AppDimensions.s,
                AppDimensions.m,
                120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RouteSelectionCard(
                    fromController: _fromController,
                    toController: _toController,
                    fromFocusNode: _fromFocusNode,
                    toFocusNode: _toFocusNode,
                    swapTurns: state.swapTurns,
                    selectedDateTime: state.selectedDateTime,
                    isSearching: state.status == JourneyPlannerStatus.loading,
                    onSwap: () => context.read<JourneyPlannerBloc>().add(const StationsSwapped()),
                    onSelectDateTime: () => _selectDateTime(context, state.selectedDateTime),
                    onSearch: () {
                      _fromFocusNode.unfocus();
                      _toFocusNode.unfocus();
                      context.read<JourneyPlannerBloc>().add(const SearchStarted());
                    },
                    onNowPressed: () => context.read<JourneyPlannerBloc>().add(DateTimeChanged(DateTime.now())),
                    formattedDateTime: _formatDateTime(state.selectedDateTime),
                    onClear: (field) {
                      if (field == 'from') {
                        context.read<JourneyPlannerBloc>().add(const FromStationChanged(''));
                      } else {
                        context.read<JourneyPlannerBloc>().add(const ToStationChanged(''));
                      }
                    },
                  ),

                  const SizedBox(height: AppDimensions.l),

                  PreferencesSection(
                    fastestRoute: state.fastestRoute,
                    directOnly: state.directOnly,
                    cheapestFirst: state.cheapestFirst,
                    onFastestRouteToggle: () => context.read<JourneyPlannerBloc>().add(const FastestRouteToggled()),
                    onDirectOnlyToggle: () => context.read<JourneyPlannerBloc>().add(const DirectOnlyToggled()),
                    onCheapestFirstToggle: () => context.read<JourneyPlannerBloc>().add(const CheapestFirstToggled()),
                  ),

                  const SizedBox(height: AppDimensions.xl),

                  if (state.status == JourneyPlannerStatus.loading)
                    const SearchingLoader()
                  else if (state.status == JourneyPlannerStatus.success)
                    ResultsSection(
                      fadeAnimation: _resultsFadeAnimation,
                      slideAnimation: _resultsSlideAnimation,
                      journeys: state.journeys,
                      fastestRoute: state.fastestRoute,
                      cheapestFirst: state.cheapestFirst,
                    )
                  else
                    RecentSearchesSection(
                      recentSearches: state.recentSearches,
                      onClearAll: () => context.read<JourneyPlannerBloc>().add(const RecentSearchesCleared()),
                      onSearchSelected: (from, to) => 
                        context.read<JourneyPlannerBloc>().add(RecentSearchSelected(from, to)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(dt.year, dt.month, dt.day);

    String dayStr;
    if (targetDate == today) {
      dayStr = 'Today';
    } else if (targetDate == tomorrow) {
      dayStr = 'Tomorrow';
    } else {
      dayStr = DateFormat('EEE, d MMM').format(dt);
    }

    return '$dayStr, ${DateFormat('HH:mm').format(dt)}';
  }
}
