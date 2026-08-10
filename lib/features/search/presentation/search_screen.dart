import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_dimensions.dart';
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
  final LayerLink _layerLink = LayerLink();
  
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _hideOverlay();
    _searchFocusNode.dispose();
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
                                          _hideOverlay();
                                          _searchFocusNode.unfocus();
                                          context.push(
                                            '/train-details/${train.id}',
                                            extra: train,
                                          );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          _hideOverlay();
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
                        CompositedTransformTarget(
                          link: _layerLink,
                          child: SearchFloatingHeader(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            isSearching: state.isSearching,
                            onChanged: (val) {
                              context.read<SearchBloc>().add(UpdateSearchQuery(val));
                              _showOverlay();
                            },
                            onClear: () {
                              _searchController.clear();
                              context.read<SearchBloc>().add(ClearSearch());
                              _showOverlay();
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

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppDimensions.m),
                            SearchSheetHeader(
                              isSearching: state.isSearching,
                            ),
                            const SizedBox(height: AppDimensions.l),
                            SearchSectionLabel(
                              label: state.isSearching ? 'SEARCH RESULTS' : 'POPULAR TRAINS',
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
                                  return TrainCard(
                                    train: train,
                                    onTap: () => context.push(
                                      '/train-details/${train.id}',
                                      extra: train,
                                    ),
                                  );
                                },
                              ),
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
}
