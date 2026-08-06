import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_card.dart';

class JourneyPlannerScreen extends StatefulWidget {
  const JourneyPlannerScreen({super.key});

  @override
  State<JourneyPlannerScreen> createState() => _JourneyPlannerScreenState();
}

class _JourneyPlannerScreenState extends State<JourneyPlannerScreen> with TickerProviderStateMixin {
  final TextEditingController _fromController = TextEditingController(text: 'Lahore Junction');
  final TextEditingController _toController = TextEditingController(text: 'Karachi Cantt');
  
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();

  DateTime _selectedDateTime = DateTime.now();
  double _swapTurns = 0.0;
  
  // Search state
  bool _isSearching = false;
  bool _hasSearched = false;
  
  // Travel preferences
  bool _directOnly = false;
  bool _fastestRoute = true;
  bool _cheapestFirst = false;

  final List<Map<String, String>> _recentSearches = [
    {'from': 'Lahore Junction', 'to': 'Rawalpindi'},
    {'from': 'Karachi Cantt', 'to': 'Multan Cantt'},
    {'from': 'Faisalabad', 'to': 'Lahore Junction'},
  ];

  late final AnimationController _loadingController;
  late final AnimationController _resultsFadeController;
  late final Animation<double> _resultsFadeAnimation;
  late final Animation<double> _resultsSlideAnimation;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
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
    _loadingController.dispose();
    _resultsFadeController.dispose();
    super.dispose();
  }

  void _swapStations() {
    if (_isSearching) return;
    
    setState(() {
      final temp = _fromController.text;
      _fromController.text = _toController.text;
      _toController.text = temp;
      _swapTurns += 0.5;
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        HapticFeedback.lightImpact();
      }
    }
  }

  void _startSearch() {
    if (_fromController.text.trim().isEmpty || _toController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both departure and destination stations'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    _fromFocusNode.unfocus();
    _toFocusNode.unfocus();

    setState(() {
      _isSearching = true;
      _hasSearched = false;
    });
    _resultsFadeController.reset();

    // Simulate search API call
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _hasSearched = true;
      });
      _resultsFadeController.forward();
      HapticFeedback.heavyImpact();
    });
  }

  void _selectRecentSearch(String from, String to) {
    setState(() {
      _fromController.text = from;
      _toController.text = to;
      _hasSearched = false;
    });
    HapticFeedback.lightImpact();
    _startSearch();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.m,
          AppDimensions.s,
          AppDimensions.m,
          120, // Clean bottom padding for navigation bar
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Route search main card
            _buildRouteCard(theme),

            const SizedBox(height: AppDimensions.l),

            // Interactive Travel Preferences / Filters
            _buildPreferencesRow(theme),

            const SizedBox(height: AppDimensions.xl),

            // Search Results or Skeleton Loader
            if (_isSearching)
              _buildSearchingLoader(theme)
            else if (_hasSearched)
              _buildSearchResults(theme)
            else
              _buildRecentSearchesSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.m),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.centerRight,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24, left: 4, right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.surface, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                )
                              ]
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: colorScheme.surface, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.secondary.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                )
                              ]
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Input TextFields
                    Expanded(
                      child: Column(
                        children: [
                          _buildStationTextField(
                            controller: _fromController,
                            focusNode: _fromFocusNode,
                            label: 'From Station',
                            hint: 'Where from?',
                            icon: Icons.location_on_rounded,
                            iconColor: colorScheme.primary,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                          ),
                          _buildStationTextField(
                            controller: _toController,
                            focusNode: _toFocusNode,
                            label: 'To Station',
                            hint: 'Where to?',
                            icon: Icons.flag_rounded,
                            iconColor: colorScheme.secondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                // Absolute positioned Swap Button with rotation animation
                Positioned(
                  right: 4,
                  child: AnimatedRotation(
                    turns: _swapTurns,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutBack,
                    child: Material(
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      shape: const CircleBorder(),
                      color: colorScheme.primary,
                      child: InkWell(
                        onTap: _swapStations,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.swap_vert_rounded,
                            color: colorScheme.onPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.m),

            // Date & Time Custom selector row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDateTime,
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: AppDimensions.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Departure Time',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDateTime(_selectedDateTime),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s),

                // Quick "Now" button shortcut
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDateTime = DateTime.now();
                      });
                      HapticFeedback.lightImpact();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                        ),
                        color: colorScheme.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Now',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.l),

            // Search trigger using our highly customized AppButton widget
            AppButton(
              label: 'Find Best Journeys',
              icon: Icons.search_rounded,
              isLoading: _isSearching,
              onPressed: _startSearch,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        filled: false,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  setState(() {
                    controller.clear();
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildPreferencesRow(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'TRAVEL PREFERENCES',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildPreferenceChip(
                theme: theme,
                icon: Icons.bolt_rounded,
                label: 'Fastest Route',
                isSelected: _fastestRoute,
                onTap: () {
                  setState(() {
                    _fastestRoute = !_fastestRoute;
                    if (_fastestRoute) _cheapestFirst = false;
                  });
                },
              ),
              const SizedBox(width: AppDimensions.s),
              _buildPreferenceChip(
                theme: theme,
                icon: Icons.directions_railway_rounded,
                label: 'Direct Only',
                isSelected: _directOnly,
                onTap: () {
                  setState(() {
                    _directOnly = !_directOnly;
                  });
                },
              ),
              const SizedBox(width: AppDimensions.s),
              _buildPreferenceChip(
                theme: theme,
                icon: Icons.savings_rounded,
                label: 'Cheapest First',
                isSelected: _cheapestFirst,
                onTap: () {
                  setState(() {
                    _cheapestFirst = !_cheapestFirst;
                    if (_cheapestFirst) _fastestRoute = false;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceChip({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.08),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
              ),
              const SizedBox(width: AppDimensions.s),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingLoader(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppDimensions.m),
            Text(
              'Searching best routes...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              'Fetching real-time timetables and fares',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    // Generate mock matching journeys
    final mockJourneys = [
      _JourneyMock(
        fromTime: '10:15',
        toTime: '14:32',
        duration: '4h 17m',
        type: 'Direct',
        price: _cheapestFirst ? 'Rs. 2,500' : 'Rs. 4,200',
        operator: 'Pakistan Railways',
        platform: 'Plat 4',
        isFastest: _fastestRoute,
        isCheapest: _cheapestFirst,
      ),
      if (!_directOnly)
        _JourneyMock(
          fromTime: '10:45',
          toTime: '15:50',
          duration: '5h 05m',
          type: '1 change',
          price: _cheapestFirst ? 'Rs. 1,800' : 'Rs. 2,800',
          operator: 'Green Line',
          platform: 'Plat 1',
          isFastest: false,
          isCheapest: !_cheapestFirst,
        ),
      _JourneyMock(
        fromTime: '11:15',
        toTime: '15:45',
        duration: '4h 30m',
        type: 'Direct',
        price: 'Rs. 3,500',
        operator: 'Tezgam',
        platform: 'Plat 8',
        isFastest: false,
        isCheapest: false,
      ),
    ];

    return AnimatedBuilder(
      animation: _resultsFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _resultsFadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _resultsSlideAnimation.value),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECOMMENDED ROUTES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${mockJourneys.length} routes found',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.m),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockJourneys.length,
            itemBuilder: (context, index) {
              return _buildJourneyCard(theme, mockJourneys[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyCard(ThemeData theme, _JourneyMock journey) {
    final colorScheme = theme.colorScheme;

    return CustomCard(
      padding: EdgeInsets.zero,
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            border: (journey.isFastest || journey.isCheapest)
                ? Border(
                    left: BorderSide(
                      color: journey.isFastest ? colorScheme.primary : colorScheme.secondary,
                      width: 5,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.m),
            child: Column(
              children: [
                // Top Tags Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (journey.isFastest)
                          _buildJourneyTag(
                            theme,
                            'FASTEST',
                            Icons.bolt_rounded,
                            colorScheme.primary.withValues(alpha: 0.1),
                            colorScheme.primary,
                          ),
                        if (journey.isCheapest)
                          _buildJourneyTag(
                            theme,
                            'CHEAPEST',
                            Icons.savings_rounded,
                            colorScheme.secondary.withValues(alpha: 0.1),
                            colorScheme.onSecondaryFixedVariant,
                          ),
                        if (!journey.isFastest && !journey.isCheapest)
                          Text(
                            journey.operator.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                              letterSpacing: 1.0,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      journey.duration,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.m),

                // Station route details with timing
                Row(
                  children: [
                    // Visual map connectors
                    Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 1.5,
                          height: 24,
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppDimensions.m),

                    // Station departures & arrivals text
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${journey.fromTime} • ${_fromController.text.split(' ').first}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                journey.platform,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${journey.toTime} • ${_toController.text.split(' ').first}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  journey.type,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.m),
                // Bottom CTA & Pricing info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_train_rounded,
                          size: 16,
                          color: colorScheme.primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: AppDimensions.xs),
                        Text(
                          journey.operator,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          journey.price,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colorScheme.primary,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.s),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyTag(
    ThemeData theme,
    String label,
    IconData icon,
    Color bg,
    Color text,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: AppDimensions.s),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: text,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT SEARCHES',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            if (_recentSearches.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _recentSearches.clear();
                  });
                  HapticFeedback.lightImpact();
                },
                child: Text(
                  'Clear All',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.s),
        if (_recentSearches.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.xl),
              child: Column(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 40,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: AppDimensions.s),
                  Text(
                    'No recent searches yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentSearches.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.s),
            itemBuilder: (context, index) {
              final search = _recentSearches[index];
              return _buildRecentSearchCard(theme, search['from']!, search['to']!);
            },
          ),
      ],
    );
  }

  Widget _buildRecentSearchCard(ThemeData theme, String from, String to) {
    final colorScheme = theme.colorScheme;

    return CustomCard(
      onTap: () => _selectRecentSearch(from, to),
      padding: const EdgeInsets.all(AppDimensions.m),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        from,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s),
                      child: Icon(
                        Icons.trending_flat_rounded,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        to,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Train Route',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }
}

class _JourneyMock {
  final String fromTime;
  final String toTime;
  final String duration;
  final String type;
  final String price;
  final String operator;
  final String platform;
  final bool isFastest;
  final bool isCheapest;

  _JourneyMock({
    required this.fromTime,
    required this.toTime,
    required this.duration,
    required this.type,
    required this.price,
    required this.operator,
    required this.platform,
    required this.isFastest,
    required this.isCheapest,
  });
}
