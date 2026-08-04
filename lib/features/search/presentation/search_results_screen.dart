import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Results')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Train ${index + 100}'),
            subtitle: const Text('Departure: 10:00 AM'),
            onTap: () => context.push('/train-details/${index + 100}'),
          );
        },
      ),
    );
  }
}
