import 'package:flutter/material.dart';
import 'core/utils/user_preferences.dart';
import 'presentation/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.load();

  runApp(const InfiniStreamApp());
}

class InfiniStreamApp extends StatelessWidget {
  const InfiniStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InfiniStream',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
