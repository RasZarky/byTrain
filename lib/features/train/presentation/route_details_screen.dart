import 'package:flutter/material.dart';

class RouteDetailsScreen extends StatelessWidget {
  final String routeId;
  const RouteDetailsScreen({super.key, required this.routeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Details')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Column(
              children: [
                const Icon(Icons.circle, size: 12),
                if (index != 9) Expanded(child: Container(width: 2, color: Colors.grey)),
              ],
            ),
            title: Text('Station ${index + 1}'),
            trailing: Text('${10 + index}:00 AM'),
          );
        },
      ),
    );
  }
}
