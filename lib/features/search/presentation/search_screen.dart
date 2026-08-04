import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Trains')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find your train',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppDimensions.s),
            Text(
              'Enter station name or train number to get started.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.l),
            CustomCard(
              child: Column(
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'From Station',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.m),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'To Station',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.l),
                  AppButton(
                    label: 'Search Trains',
                    icon: Icons.search,
                    onPressed: () => context.push('/search-results'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
