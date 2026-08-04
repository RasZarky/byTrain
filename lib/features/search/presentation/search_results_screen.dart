import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/custom_card.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Results')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.m),
        itemCount: 5,
        itemBuilder: (context, index) {
          final trainId = (index + 101).toString();
          return CustomCard(
            onTap: () => context.push('/train-details/$trainId'),
            padding: EdgeInsets.zero,
            child: ListTile(
              title: Text(
                'Express $trainId',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: const Text('Departure: 10:00 AM • Platform 4'),
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.train_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
