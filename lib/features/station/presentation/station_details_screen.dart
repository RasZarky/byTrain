import 'package:flutter/material.dart';

class StationDetailsScreen extends StatelessWidget {
  final String stationId;
  const StationDetailsScreen({super.key, required this.stationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Station $stationId')),
      body: const Center(
        child: Text('Station Details and Facilities'),
      ),
    );
  }
}
