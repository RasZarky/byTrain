import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../train/domain/models/train.dart';
import '../../train/presentation/widgets/train_card.dart';
import 'bloc/search_bloc.dart';
import 'widgets/map_action_button.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/search_floating_header.dart';
import 'widgets/search_section_label.dart';
import 'widgets/search_sheet_handle.dart';
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

class _SearchScreenBodyState extends State<SearchScreenBody> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  late AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  
  OverlayEntry? _overlayEntry;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(31.5741, 74.3485),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController);
    
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _showOverlay();
      } else {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !_searchFocusNode.hasFocus) {
            _hideOverlay();
          }
        });
      }
    });

    _requestLocationPermission();
  }

  @override
  void dispose() {
    _hideOverlay();
    _searchFocusNode.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showOverlay() {
    if (!mounted) return;
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    final searchBloc = context.read<SearchBloc>();

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - (AppDimensions.m * 2),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 68),
          child: BlocProvider.value(
            value: searchBloc,
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                final filteredTrains = state.filteredTrains;
                return Material(
                  elevation: 20,
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 350),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            )
                          ]
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                              child: Text(
                                state.searchQuery.isEmpty ? 'POPULAR TRAINS' : 'SUGGESTIONS',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            Flexible(
                              child: filteredTrains.isEmpty 
                                ? Padding(
                                    padding: const EdgeInsets.all(AppDimensions.xl),
                                    child: Center(
                                      child: Text(
                                        'No matching trains found',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    shrinkWrap: true,
                                    itemCount: filteredTrains.length,
                                    separatorBuilder: (context, index) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Divider(
                                        height: 1, 
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)
                                      ),
                                    ),
                                    itemBuilder: (context, index) {
                                      final train = filteredTrains[index];
                                      return ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.train_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                                        ),
                                        title: Text(
                                          train.name,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${train.number} • ${train.departureTime}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        trailing: Icon(Icons.arrow_outward_rounded, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                                        onTap: () {
                                          context.read<SearchBloc>().add(SelectTrain(train));
                                          _hideOverlay();
                                          _searchFocusNode.unfocus();
                                        },
                                      );
                                    },
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (mounted) {
      context.read<SearchBloc>().add(UpdateLocationPermission(status.isGranted));
    }
  }

  Future<void> _moveCameraTo(Train train) async {
    if (train.latitude == null || train.longitude == null) return;
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(train.latitude!, train.longitude!), 
        15,
      ),
    );
  }

  Set<Marker> _buildMarkers(SearchState state) {
    final markers = <Marker>{};
    for (final train in state.filteredTrains) {
      if (train.latitude != null && train.longitude != null) {
        final isSelected = train == state.selectedTrain;
        markers.add(
          Marker(
            markerId: MarkerId('train_${train.id}'),
            position: LatLng(train.latitude!, train.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isSelected ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure
            ),
            zIndexInt: isSelected ? 1 : 0,
            onTap: () => context.read<SearchBloc>().add(SelectTrain(train)),
          ),
        );
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          _hideOverlay();
        },
        child: BlocListener<SearchBloc, SearchState>(
          listenWhen: (previous, current) => previous.selectedTrain != current.selectedTrain,
          listener: (context, state) {
            if (state.selectedTrain != null) {
              _searchController.text = state.selectedTrain!.name;
              _moveCameraTo(state.selectedTrain!);
            }
          },
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              return Stack(
                children: [
                  // 1. Google Map
                  GoogleMap(
                    initialCameraPosition: _initialPosition,
                    markers: _buildMarkers(state),
                    onMapCreated: (controller) => _mapController.complete(controller),
                    onTap: (_) {
                      context.read<SearchBloc>().add(const SelectTrain(null));
                      _searchFocusNode.unfocus();
                      _hideOverlay();
                    },
                    mapType: state.mapType,
                    myLocationEnabled: state.locationPermissionGranted,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),

                  // 2. Top Scrim
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: topPadding + 120,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                              theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Floating Search Bar & Filters
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.m,
                        vertical: AppDimensions.s,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CompositedTransformTarget(
                            link: _layerLink,
                            child: SearchFloatingHeader(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              isSearching: state.isSearching,
                              onChanged: (val) {
                                context.read<SearchBloc>().add(UpdateSearchQuery(val));
                                _showOverlay(); // Always show overlay when typing
                              },
                              onClear: () {
                                _searchController.clear();
                                context.read<SearchBloc>().add(ClearSearch());
                                _showOverlay(); // Re-show popular trains
                              },
                            ),
                          ),
                          const SizedBox(height: AppDimensions.s),
                          SearchFilterBar(
                            selectedFilter: state.selectedFilter,
                            onFilterSelected: (filter) {
                              context.read<SearchBloc>().add(SelectFilter(filter));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Floating Map Actions
                  Positioned(
                    right: AppDimensions.m,
                    top: size.height * 0.25,
                    child: Column(
                      children: [
                        MapActionButton(
                          icon: Icons.my_location_rounded,
                          onTap: () async {
                            if (!state.locationPermissionGranted) {
                              await _requestLocationPermission();
                            }
                            if (state.locationPermissionGranted) {
                              try {
                                final position = await Geolocator.getCurrentPosition();
                                final controller = await _mapController.future;
                                controller.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(position.latitude, position.longitude),
                                    15,
                                  ),
                                );
                              } catch (e) {
                                final controller = await _mapController.future;
                                controller.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
                              }
                            }
                          },
                        ),
                        const SizedBox(height: AppDimensions.m),
                        MapActionButton(
                          icon: Icons.layers_outlined,
                          onTap: () {
                            context.read<SearchBloc>().add(CycleMapType());
                          },
                        ),
                      ],
                    ),
                  ),

                  // 5. Draggable Results Sheet
                  DraggableScrollableSheet(
                    initialChildSize: 0.2,
                    minChildSize: 0.18,
                    maxChildSize: 0.84,
                    snap: true,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 30,
                              offset: const Offset(0, -10),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              const SearchSheetHandle(),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SearchSheetHeader(
                                      isSearching: state.isSearching,
                                      pulseAnimation: _pulseAnimation,
                                    ),
                                    const SizedBox(height: AppDimensions.l),
                                    if (state.selectedTrain != null && state.filteredTrains.contains(state.selectedTrain)) ...[
                                      SearchSectionLabel(
                                        label: 'SELECTED TRAIN',
                                        trailing: IconButton(
                                          icon: const Icon(Icons.close_rounded, size: 16),
                                          onPressed: () {
                                            context.read<SearchBloc>().add(const SelectTrain(null));
                                          },
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: AppDimensions.s),
                                      TrainCard(
                                        train: state.selectedTrain!,
                                        isSelected: true,
                                        heroTag: 'selected_${state.selectedTrain!.id}',
                                        onTap: () => context.push('/train-details/${state.selectedTrain!.id}'),
                                      ),
                                      const SizedBox(height: AppDimensions.xl),
                                    ],
                                    SearchSectionLabel(
                                      label: state.isSearching ? 'SEARCH RESULTS' : 'LIVE NEARBY',
                                    ),
                                    const SizedBox(height: AppDimensions.m),
                                    if (state.filteredTrains.isEmpty)
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: AppDimensions.xl),
                                          child: Column(
                                            children: [
                                              Icon(Icons.search_off_rounded, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                                              const SizedBox(height: AppDimensions.m),
                                              Text(
                                                'No trains found',
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      ListView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: state.filteredTrains.length,
                                        itemBuilder: (context, index) {
                                          final train = state.filteredTrains[index];
                                          if (train == state.selectedTrain) return const SizedBox.shrink();
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: AppDimensions.m),
                                            child: TrainCard(
                                              train: train,
                                              onTap: () => context.read<SearchBloc>().add(SelectTrain(train)),
                                            ),
                                          );
                                        },
                                      ),
                                    const SizedBox(height: 120),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
