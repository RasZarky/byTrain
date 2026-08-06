import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/custom_card.dart';
import '../../train/domain/models/train.dart';

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
          final train = Train(
            id: trainId,
            name: 'Express $trainId',
            number: '${trainId}UP',
            status: index % 2 == 0 ? 'On Time' : 'Delayed 10m',
            departureTime: '10:00 AM',
            arrivalTime: '04:00 PM',
            type: TrainType.express,
            stops: [
              TrainStop(
                stationName: 'Origin Station $trainId',
                arrivalTime: '10:00 AM',
                status: StopStatus.passed,
              ),
              TrainStop(
                stationName: 'Middle Station $trainId',
                arrivalTime: '01:00 PM',
                status: StopStatus.current,
              ),
              TrainStop(
                stationName: 'Final Destination $trainId',
                arrivalTime: '04:00 PM',
                status: StopStatus.upcoming,
              ),
            ],
          );

          return CustomCard(
            onTap: () => context.push('/train-details/$trainId', extra: train),
            padding: EdgeInsets.zero,
            child: ListTile(
              title: Text(
                train.name,
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text('Departure: ${train.departureTime} • Status: ${train.status}'),
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
