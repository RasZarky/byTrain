import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About ByTrain')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ByTrain v1.0.0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('A comprehensive train timing tracking application built with Flutter.'),
            SizedBox(height: 20),
            Text('Developed with:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• GoRouter for navigation'),
            Text('• BLoC for state management'),
            Text('• Skeletonizer for loading states'),
          ],
        ),
      ),
    );
  }
}
