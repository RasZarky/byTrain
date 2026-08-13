import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/theme/app_dimensions.dart';
import '../../journey_planner/domain/models/journey.dart';
import '../../station/domain/models/station.dart';
import '../../train/domain/models/train.dart';
import '../../train/presentation/widgets/train_card.dart';
import 'bloc/search_bloc.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/search_floating_header.dart';
import 'widgets/search_section_label.dart';
import 'widgets/search_sheet_header.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (context) => SearchBloc()..add(LoadTrains()),
      child: const SearchScreenBody(),
    );
  }
}

class SearchScreenBody extends StatefulWidget {
  const SearchScreenBody({super.key});

  @override
  State<SearchScreenBody> createState() => _SearchScreenBodyState();
}

class _SearchScreenBodyState extends State<SearchScreenBody> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _voiceActive = false;
  bool _speechInitialized = false;

  @override
  void dispose() {
    if (_speechInitialized) {
      _speech.cancel();
    }
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Toggles voice input. On: initializes speech recognition, focuses the
  /// search field and starts listening. Off: stops listening.
  Future<void> _toggleVoice() async {
    if (_voiceActive) {
      await _stopVoice();
      return;
    }
    try {
      if (!_speechInitialized) {
        _speechInitialized = await _speech.initialize(
          onError: (error) => _onVoiceError(error.errorMsg),
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              if (mounted && _voiceActive) {
                setState(() => _voiceActive = false);
              }
            }
          },
        );
      }
      if (!_speechInitialized) {
        _showVoiceUnavailable();
        return;
      }
      await _speech.listen(
        onResult: (result) => _onVoiceResult(result),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
        ),
      );
      if (mounted) {
        setState(() => _voiceActive = true);
      }
    } catch (_) {
      _showVoiceUnavailable();
    }
  }

  /// Feeds recognized speech into the search field and results.
  void _onVoiceResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords;
    if (!mounted || text.isEmpty) return;
    _searchController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    context.read<SearchBloc>().add(UpdateSearchQuery(text));
  }

  void _onVoiceError(String message) {
    if (!mounted) return;
    setState(() => _voiceActive = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.isEmpty
              ? 'Voice input stopped'
              : 'Voice input error: $message',
        ),
      ),
    );
  }

  Future<void> _stopVoice() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    if (mounted) {
      setState(() => _voiceActive = false);
    }
  }

  void _showVoiceUnavailable() {
    if (!mounted) return;
    setState(() => _voiceActive = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input is not available on this device'),
      ),
    );
  }

  void _openTrain(BuildContext context, Train train) {
    _searchFocusNode.unfocus();
    context.push('/train-details/${train.id}', extra: train);
  }

  void _openStation(BuildContext context, Station station) {
    _searchFocusNode.unfocus();
    context.push('/station-details/${station.id}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
        },
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.m,
                      vertical: AppDimensions.s,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SearchFloatingHeader(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          isSearching: state.isSearching,
                          voiceActive: _voiceActive,
                          onChanged: (val) {
                            // User took over typing — end voice input.
                            if (_voiceActive) {
                              _stopVoice();
                            }
                            context.read<SearchBloc>().add(
                              UpdateSearchQuery(val),
                            );
                          },
                          onClear: () {
                            _searchController.clear();
                            context.read<SearchBloc>().add(const ClearSearch());
                          },
                          onVoiceTap: _toggleVoice,
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _voiceActive
                              ? Padding(
                                  key: const ValueKey('voice-indicator'),
                                  padding: const EdgeInsets.only(
                                    top: AppDimensions.s,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.mic_rounded,
                                        size: 14,
                                        color: theme.colorScheme.error,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Listening… tap the mic to stop',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: theme.colorScheme.error,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey('voice-indicator-off'),
                                ),
                        ),
                        const SizedBox(height: AppDimensions.s),
                        SearchFilterBar(
                          selectedContentFilter: state.contentFilter,
                          onContentFilterSelected: (filter) {
                            context.read<SearchBloc>().add(
                              SelectContentFilter(filter),
                            );
                          },
                          selectedFilter: state.selectedFilter,
                          onFilterSelected: (filter) {
                            context.read<SearchBloc>().add(
                              SelectFilter(filter),
                            );
                          },
                          showClassFilter:
                              state.contentFilter == 'All' ||
                              state.contentFilter == 'Trains',
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.m,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppDimensions.m),
                            SearchSheetHeader(isSearching: state.isSearching),
                            const SizedBox(height: AppDimensions.l),
                            _buildResultSections(context, state),
                            const SizedBox(height: AppDimensions.xl),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultSections(BuildContext context, SearchState state) {
    final theme = Theme.of(context);
    final showStations =
        state.contentFilter == 'All' || state.contentFilter == 'Stations';
    final showRoutes =
        state.contentFilter == 'All' || state.contentFilter == 'Routes';
    final showTrains =
        state.contentFilter == 'All' || state.contentFilter == 'Trains';

    final hasStations = showStations && state.stationResults.isNotEmpty;
    final hasRoutes = showRoutes && state.routeResults.isNotEmpty;
    final hasTrains = showTrains && state.filteredTrains.isNotEmpty;
    final hasAny = hasStations || hasRoutes || hasTrains;

    if (!hasAny) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.xl),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(height: AppDimensions.m),
              Text(
                'No results found',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sections = <Widget>[];

    if (hasStations) {
      sections.add(
        SearchSectionLabel(
          label: state.isSearching ? 'STATIONS' : 'ALL STATIONS',
        ),
      );
      sections.add(const SizedBox(height: AppDimensions.s));
      sections.addAll(
        state.stationResults.map(
          (s) =>
              _StationTile(station: s, onTap: () => _openStation(context, s)),
        ),
      );
      sections.add(const SizedBox(height: AppDimensions.l));
    }

    if (hasRoutes) {
      sections.add(
        SearchSectionLabel(label: state.isSearching ? 'ROUTES' : 'ALL ROUTES'),
      );
      sections.add(const SizedBox(height: AppDimensions.s));
      sections.addAll(
        state.routeResults.map(
          (r) =>
              _RouteTile(journey: r, onTap: () => _openTrain(context, r.train)),
        ),
      );
      sections.add(const SizedBox(height: AppDimensions.l));
    }

    if (hasTrains) {
      sections.add(
        SearchSectionLabel(label: state.isSearching ? 'TRAINS' : 'ALL TRAINS'),
      );
      sections.add(const SizedBox(height: AppDimensions.m));
      sections.addAll(
        state.filteredTrains.map(
          (train) =>
              TrainCard(train: train, onTap: () => _openTrain(context, train)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }
}

class _StationTile extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;

  const _StationTile({required this.station, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.location_on_outlined,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        station.name,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: station.code.isNotEmpty
          ? Text(
              'Station ${station.code}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }
}

class _RouteTile extends StatelessWidget {
  final Journey journey;
  final VoidCallback onTap;

  const _RouteTile({required this.journey, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dep = DateFormat('HH:mm').format(journey.departureTime);
    final arr = DateFormat('HH:mm').format(journey.arrivalTime);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.route_rounded,
          color: theme.colorScheme.secondary,
          size: 20,
        ),
      ),
      title: Text(
        '${journey.train.name} #${journey.train.number}',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${journey.from.name} → ${journey.to.name} · $dep–$arr',
        style: theme.textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }
}
