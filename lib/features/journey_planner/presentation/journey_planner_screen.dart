import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/data/pakrail_repository.dart';
import '../../../core/data/saved_journeys_store.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/format.dart';
import '../domain/models/journey.dart';
import '../domain/models/saved_journey.dart';
import '../../station/domain/models/station.dart';
import 'bloc/journey_planner_bloc.dart';
import 'bloc/journey_planner_event.dart';
import 'bloc/journey_planner_state.dart';
import 'widgets/preferences_section.dart';
import 'widgets/results_section.dart';
import 'widgets/route_selection_card.dart';
import 'widgets/searching_loader.dart';
import 'widgets/station_picker_sheet.dart';

class JourneyPlannerScreen extends StatelessWidget {
  const JourneyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JourneyPlannerBloc(repository: PakRailRepository()),
      child: const JourneyPlannerView(),
    );
  }
}

class JourneyPlannerView extends StatefulWidget {
  const JourneyPlannerView({super.key});

  @override
  State<JourneyPlannerView> createState() => _JourneyPlannerViewState();
}

class _JourneyPlannerViewState extends State<JourneyPlannerView>
    with TickerProviderStateMixin {
  late final TextEditingController _fromController;
  late final TextEditingController _toController;

  late final PakRailRepository _repository;

  /// Identities of journeys already saved (train id + departure time), used
  /// to show a saved indicator on the result cards.
  Set<String> _savedKeys = const {};

  late final AnimationController _resultsFadeController;
  late final Animation<double> _resultsFadeAnimation;
  late final Animation<double> _resultsSlideAnimation;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<JourneyPlannerBloc>();
    _repository = PakRailRepository();
    _fromController = TextEditingController(text: bloc.state.from?.name ?? '');
    _toController = TextEditingController(text: bloc.state.to?.name ?? '');

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

    _loadSavedKeys();
  }

  Future<void> _loadSavedKeys() async {
    final saved = await SavedJourneysStore().load();
    if (!mounted) return;
    setState(() {
      _savedKeys = {for (final j in saved) j.key};
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _resultsFadeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(
    BuildContext context,
    DateTime currentDateTime,
  ) async {
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

  Future<void> _saveJourney(Journey journey) async {
    final savedJourney = SavedJourney.fromJourney(journey);
    final added = await SavedJourneysStore().add(savedJourney);
    if (!mounted) return;
    setState(() {
      _savedKeys = {..._savedKeys, savedJourney.key};
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? 'Journey saved — view it on Home'
              : 'This journey is already saved',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showStationPicker({required bool isFrom}) async {
    final stations = await _repository.loadStations();
    if (!mounted) return;
    final selected = await showModalBottomSheet<Station>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StationPickerSheet(
        stations: stations,
        title: isFrom
            ? 'Choose Departure Station'
            : 'Choose Destination Station',
      ),
    );
    if (selected != null && mounted) {
      final bloc = context.read<JourneyPlannerBloc>();
      bloc.add(
        isFrom ? FromStationSelected(selected) : ToStationSelected(selected),
      );
      if (isFrom) {
        _fromController.text = selected.name;
      } else {
        _toController.text = selected.name;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocListener<JourneyPlannerBloc, JourneyPlannerState>(
      listener: (context, state) {
        if (state.status == JourneyPlannerStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }

        if (_fromController.text != (state.from?.name ?? '')) {
          _fromController.text = state.from?.name ?? '';
        }
        if (_toController.text != (state.to?.name ?? '')) {
          _toController.text = state.to?.name ?? '';
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
          toolbarHeight: screenWidth < 360 ? 110 : 130,
          centerTitle: false,
          titleSpacing: 12,
          title: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Where are we heading?',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      letterSpacing: -1.2,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Plan your next train adventure effortlessly.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: BlocBuilder<JourneyPlannerBloc, JourneyPlannerState>(
          builder: (context, state) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, AppDimensions.s, 12, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RouteSelectionCard(
                    fromController: _fromController,
                    toController: _toController,
                    onFromTap: () => _showStationPicker(isFrom: true),
                    onToTap: () => _showStationPicker(isFrom: false),
                    swapTurns: state.swapTurns,
                    selectedDateTime: state.selectedDateTime,
                    isSearching: state.status == JourneyPlannerStatus.loading,
                    onSwap: () => context.read<JourneyPlannerBloc>().add(
                      const StationsSwapped(),
                    ),
                    onSelectDateTime: () =>
                        _selectDateTime(context, state.selectedDateTime),
                    onSearch: () {
                      context.read<JourneyPlannerBloc>().add(
                        const SearchStarted(),
                      );
                    },
                    onNowPressed: () => context.read<JourneyPlannerBloc>().add(
                      DateTimeChanged(DateTime.now()),
                    ),
                    formattedDateTime: _formatDateTime(state.selectedDateTime),
                  ),

                  const SizedBox(height: AppDimensions.l),

                  PreferencesSection(
                    fastestRoute: state.fastestRoute,
                    directOnly: state.directOnly,
                    onFastestRouteToggle: () => context
                        .read<JourneyPlannerBloc>()
                        .add(const FastestRouteToggled()),
                    onDirectOnlyToggle: () => context
                        .read<JourneyPlannerBloc>()
                        .add(const DirectOnlyToggled()),
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
                      savedKeys: _savedKeys,
                      onSaveJourney: _saveJourney,
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

    return '$dayStr, ${formatClockTime(dt)}';
  }
}
