import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _key = 'my_streamings';
  static final Set<String> myStreamings = {};

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    myStreamings
      ..clear()
      ..addAll(list);
  }

  static bool hasStreaming(String name) {
    return myStreamings.contains(name);
  }

  static Future<void> toggleStreaming(String name) async {
    if (myStreamings.contains(name)) {
      myStreamings.remove(name);
    } else {
      myStreamings.add(name);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, myStreamings.toList());
  }
}
