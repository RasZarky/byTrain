import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/pakrail_repository.dart';
import '../../../core/theme/app_dimensions.dart';
import '../domain/models/train.dart';
import 'widgets/train_card.dart';

class TrainsScreen extends StatefulWidget {
  const TrainsScreen({super.key});

  @override
  State<TrainsScreen> createState() => _TrainsScreenState();
}

class _TrainsScreenState extends State<TrainsScreen> {
  final PakRailRepository _repository = PakRailRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Train> _trains = const [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final trains = await _repository.loadAllTrains();
      trains.sort((a, b) => a.name.compareTo(b.name));
      if (!mounted) return;
      setState(() {
        _trains = trains;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Train> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _trains;
    return [
      for (final train in _trains)
        if (train.name.toLowerCase().contains(q) ||
            train.number.toLowerCase().contains(q) ||
            train.id.toLowerCase().contains(q))
          train,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: AppDimensions.m,
                bottom: 16,
              ),
              centerTitle: false,
              title: Text(
                'Trains',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  color: colorScheme.onSurface,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.05),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.m,
              0,
              AppDimensions.m,
              AppDimensions.s,
            ),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search trains',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.xl),
                  child: Text(
                    'Could not load trains: $_error',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ),
            )
          else if (_filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No trains found',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.m,
                AppDimensions.s,
                AppDimensions.m,
                100,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == 0) {
                    final count = _filtered.length;
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        bottom: AppDimensions.m,
                      ),
                      child: Text(
                        '$count ${count == 1 ? 'train' : 'trains'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    );
                  }
                  final train = _filtered[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.s),
                    child: TrainCard(
                      train: train,
                      onTap: () => context.push(
                        '/train-details/${train.id}',
                        extra: train,
                      ),
                    ),
                  );
                }, childCount: _filtered.length + 1),
              ),
            ),
        ],
      ),
    );
  }
}
