import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../station/domain/models/station.dart';

/// Searchable bottom sheet for choosing a departure/destination station from
/// the real dataset.
class StationPickerSheet extends StatefulWidget {
  final List<Station> stations;
  final String title;

  const StationPickerSheet({
    super.key,
    required this.stations,
    required this.title,
  });

  @override
  State<StationPickerSheet> createState() => _StationPickerSheetState();
}

class _StationPickerSheetState extends State<StationPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Station> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.stations;
    return widget.stations.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.code.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stations = _filtered;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.m,
                AppDimensions.m,
                AppDimensions.m,
                AppDimensions.s,
              ),
              child: Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search stations by name or code',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.s),
            Expanded(
              child: stations.isEmpty
                  ? Center(
                      child: Text(
                        'No matching stations',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: stations.length,
                      itemBuilder: (context, index) {
                        final station = stations[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            station.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: station.code.isNotEmpty
                              ? Text(
                                  station.code,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(station),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
