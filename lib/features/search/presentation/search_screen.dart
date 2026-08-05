import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../train/domain/models/train.dart';
import '../../train/presentation/widgets/train_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  late AnimationController _pulseController;
  
  OverlayEntry? _overlayEntry;
  Train? _selectedTrain;
  bool _isSearching = false;
  bool _locationPermissionGranted = false;
  MapType _currentMapType = MapType.normal;
  String _selectedFilter = 'All';

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(31.5741, 74.3485),
    zoom: 13,
  );

  final Set<Marker> _markers = {};

  final List<Train> _mockTrains = [
    const Train(
      id: '1',
      name: 'Karakoram Express',
      number: '41UP',
      status: 'On Time',
      departureTime: '15:30',
      arrivalTime: '10:00',
      type: TrainType.express,
      latitude: 31.5741,
      longitude: 74.3485,
    ),
    const Train(
      id: '2',
      name: 'Tezgam',
      number: '7UP',
      status: 'Delayed 15m',
      departureTime: '08:00',
      arrivalTime: '13:15',
      type: TrainType.express,
      latitude: 31.5546,
      longitude: 74.3122,
    ),
    const Train(
      id: '3',
      name: 'Green Line',
      number: '5UP',
      status: 'On Time',
      departureTime: '22:00',
      arrivalTime: '20:30',
      type: TrainType.express,
      latitude: 31.4826,
      longitude: 74.3052,
    ),
    const Train(
      id: '4',
      name: 'Lahore Passenger',
      number: '212DN',
      status: 'On Time',
      departureTime: '11:00',
      arrivalTime: '14:30',
      type: TrainType.regional,
      latitude: 31.5204,
      longitude: 74.3587,
    ),
    const Train(
      id: '5',
      name: 'Babu Passenger',
      number: '208DN',
      status: 'Delayed 45m',
      departureTime: '16:00',
      arrivalTime: '18:15',
      type: TrainType.regional,
      latitude: 31.5100,
      longitude: 74.3300,
    ),
  ];

  List<Train> get _filteredTrains {
    final query = _searchController.text.toLowerCase();
    return _mockTrains.where((train) {
      final matchesQuery = train.name.toLowerCase().contains(query) || 
                          train.number.toLowerCase().contains(query);
      
      bool matchesFilter = true;
      if (_selectedFilter == 'Express') {
        matchesFilter = train.type == TrainType.express;
      } else if (_selectedFilter == 'Regional') {
        matchesFilter = train.type == TrainType.regional;
      } else if (_selectedFilter == 'Delayed') {
        matchesFilter = train.status.toLowerCase().contains('delayed');
      }

      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
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
    _loadMarkers();
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

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - (AppDimensions.m * 2),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 68),
          child: Material(
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
                          _searchController.text.isEmpty ? 'POPULAR TRAINS' : 'SUGGESTIONS',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Flexible(
                        child: _filteredTrains.isEmpty 
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
                              itemCount: _filteredTrains.length,
                              separatorBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Divider(
                                  height: 1, 
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)
                                ),
                              ),
                              itemBuilder: (context, index) {
                                final train = _filteredTrains[index];
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
                                    _selectTrain(train);
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
          ),
        ),
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (mounted) {
      setState(() {
        _locationPermissionGranted = status.isGranted;
      });
    }
  }

  void _loadMarkers() {
    setState(() {
      _markers.clear();
      for (final train in _filteredTrains) {
        if (train.latitude != null && train.longitude != null) {
          final isSelected = train == _selectedTrain;
          _markers.add(
            Marker(
              markerId: MarkerId('train_${train.id}'),
              position: LatLng(train.latitude!, train.longitude!),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                isSelected ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure
              ),
              zIndexInt: isSelected ? 1 : 0,
              onTap: () => _selectTrain(train),
            ),
          );
        }
      }
    });
  }

  void _selectTrain(Train train) {
    setState(() {
      _selectedTrain = train;
      _searchController.text = train.name;
      _isSearching = true;
    });
    _loadMarkers();
    _moveCameraTo(train);
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

  void _cycleMapType() {
    setState(() {
      if (_currentMapType == MapType.normal) {
        _currentMapType = MapType.satellite;
      } else if (_currentMapType == MapType.satellite) {
        _currentMapType = MapType.hybrid;
      } else if (_currentMapType == MapType.hybrid) {
        _currentMapType = MapType.terrain;
      } else {
        _currentMapType = MapType.normal;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final filteredTrains = _filteredTrains;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          _hideOverlay();
        },
        child: Stack(
          children: [
            // 1. Google Map
            GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: _markers,
              onMapCreated: (controller) => _mapController.complete(controller),
              onTap: (_) {
                setState(() => _selectedTrain = null);
                _loadMarkers();
                _searchFocusNode.unfocus();
                _hideOverlay();
              },
              mapType: _currentMapType,
              myLocationEnabled: _locationPermissionGranted,
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
                      child: _buildFloatingHeader(theme),
                    ),
                    const SizedBox(height: AppDimensions.s),
                    _buildFilterBar(theme),
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
                  _buildMapAction(
                    theme: theme,
                    icon: Icons.my_location_rounded,
                    onTap: () async {
                      if (!_locationPermissionGranted) {
                        await _requestLocationPermission();
                      }
                      if (_locationPermissionGranted) {
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
                  _buildMapAction(
                    theme: theme,
                    icon: Icons.layers_outlined,
                    onTap: _cycleMapType,
                  ),
                ],
              ),
            ),

            // 5. Draggable Results Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.18,
              maxChildSize: 0.9,
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
                        _buildHandle(theme),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSheetHeader(theme),
                              const SizedBox(height: AppDimensions.l),
                              if (_selectedTrain != null && filteredTrains.contains(_selectedTrain)) ...[
                                _buildSectionLabel(
                                  theme, 
                                  'SELECTED TRAIN',
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 16),
                                    onPressed: () {
                                      setState(() => _selectedTrain = null);
                                      _loadMarkers();
                                    },
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.s),
                                TrainCard(
                                  train: _selectedTrain!,
                                  isSelected: true,
                                  heroTag: 'selected_${_selectedTrain!.id}',
                                  onTap: () => context.push('/train-details/${_selectedTrain!.id}'),
                                ),
                                const SizedBox(height: AppDimensions.xl),
                              ],
                              _buildSectionLabel(theme, _isSearching ? 'SEARCH RESULTS' : 'LIVE NEARBY'),
                              const SizedBox(height: AppDimensions.m),
                              if (filteredTrains.isEmpty)
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
                                  itemCount: filteredTrains.length,
                                  itemBuilder: (context, index) {
                                    final train = filteredTrains[index];
                                    if (train == _selectedTrain) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: AppDimensions.m),
                                      child: TrainCard(
                                        train: train,
                                        onTap: () => _selectTrain(train),
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
        ),
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildFloatingHeader(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (val) {
                setState(() {
                  _isSearching = val.isNotEmpty;
                });
                _showOverlay(); // Always show overlay when typing
                _loadMarkers();
              },
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Search train, station or route...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                suffixIcon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isSearching
                      ? IconButton(
                          key: const ValueKey('clear'),
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _isSearching = false;
                              _selectedTrain = null;
                            });
                            _showOverlay(); // Re-show popular trains
                            _loadMarkers();
                          },
                        )
                      : const Icon(
                          Icons.mic_none_rounded,
                          key: ValueKey('mic'),
                        ),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    final filters = ['All', 'Express', 'Regional', 'Delayed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final bool isSelected = f == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = f;
                });
                _loadMarkers();
                if (_overlayEntry != null) _overlayEntry!.markNeedsBuild();
              },
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              checkmarkColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                side: BorderSide(
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                ),
              ),
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSheetHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ).createShader(bounds),
          child: Text(
            _isSearching ? 'Search Results' : 'Live Tracking',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
        ),
        if (!_isSearching)
          FadeTransition(
            opacity: Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_checked, size: 12, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 10,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildMapAction({
    required ThemeData theme,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}
