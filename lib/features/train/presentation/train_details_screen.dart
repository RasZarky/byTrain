import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TrainDetailsScreen extends StatelessWidget {
  final String trainId;
  const TrainDetailsScreen({super.key, required this.trainId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Train $trainId Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              title: Text('Status'),
              trailing: Text('On Time', style: TextStyle(color: Colors.green)),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => context.push('/route-details/$trainId'),
            child: const Text('View Full Route'),
          ),
        ],
      ),
    );
  }
}
