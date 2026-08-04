import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_card.dart';

class TrainDetailsScreen extends StatelessWidget {
  final String trainId;
  const TrainDetailsScreen({super.key, required this.trainId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Train $trainId')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: AppDimensions.l),
            _buildStatusCard(theme),
            const SizedBox(height: AppDimensions.m),
            _buildScheduleCard(theme),
            const SizedBox(height: AppDimensions.l),
            AppButton(
              label: 'View Full Route',
              icon: Icons.map_outlined,
              onPressed: () => context.push('/route-details/$trainId'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'train-icon-$trainId',
          child: CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.train_outlined,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.m),
        Text('Express $trainId', style: theme.textTheme.headlineMedium),
        Text('Train Number: EXP$trainId', style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.s),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: const Icon(Icons.check_circle_outline, color: Colors.green),
          ),
          const SizedBox(width: AppDimensions.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Status', style: theme.textTheme.titleMedium),
                const Text(
                  'On Time',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ThemeData theme) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.departure_board),
            title: const Text('Departure'),
            subtitle: const Text('London St Pancras'),
            trailing: Text('10:00 AM', style: theme.textTheme.titleMedium),
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.more_vert),
            title: Text('Duration'),
            subtitle: Text('4h 00m'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Arrival'),
            subtitle: const Text('Paris Gare du Nord'),
            trailing: Text('02:00 PM', style: theme.textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}
