import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_card.dart';

class JourneyPlannerScreen extends StatelessWidget {
  const JourneyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Journey Planner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan your trip',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppDimensions.s),
            Text(
              'Enter your departure and destination stations to find the best routes.',
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
                  const SizedBox(height: AppDimensions.m),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Date & Time',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      hintText: 'Today, Now',
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: AppDimensions.l),
                  AppButton(
                    label: 'Find Journeys',
                    icon: Icons.directions_railway_outlined,
                    onPressed: () {
                      // Implementation for planning
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.l),
            Text(
              'Recent Searches',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.m),
            _buildRecentSearch(theme, 'London', 'Paris'),
            _buildRecentSearch(theme, 'Manchester', 'Liverpool'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearch(ThemeData theme, String from, String to) {
    return CustomCard(
      onTap: () {},
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m, vertical: AppDimensions.s),
      child: Row(
        children: [
          Icon(Icons.history, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(width: AppDimensions.m),
          Expanded(
            child: Text('$from to $to', style: theme.textTheme.bodyLarge),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
