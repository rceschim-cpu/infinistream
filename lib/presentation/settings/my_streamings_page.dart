import 'package:flutter/material.dart';
import '../../core/utils/user_preferences.dart';

class MyStreamingsPage extends StatefulWidget {
  const MyStreamingsPage({super.key});

  @override
  State<MyStreamingsPage> createState() => _MyStreamingsPageState();
}

class _MyStreamingsPageState extends State<MyStreamingsPage> {
  final List<String> streamings = [
    'Netflix',
    'Prime Video',
    'Disney+',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Streamings')),
      body: ListView(
        children: streamings.map((name) {
          return SwitchListTile(
            title: Text(name),
            value: UserPreferences.hasStreaming(name),
            onChanged: (_) async {
              await UserPreferences.toggleStreaming(name);
              setState(() {});
            },
          );
        }).toList(),
      ),
    );
  }
}
