import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('About ByTrain'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/about'),
          ),
          const ListTile(
            title: const Text('Notifications'),
            trailing: Icon(Icons.notifications_none),
          ),
          const ListTile(
            title: const Text('Dark Mode'),
            trailing: Icon(Icons.dark_mode_outlined),
          ),
        ],
      ),
    );
  }
}
