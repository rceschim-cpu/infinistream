import '../services/auth_service.dart';
import '../services/streaming_account_service.dart';

class UserPreferences {
  static Future<void> load() async {
    await AuthService.init(); // Firebase gerencia auth automaticamente
    await StreamingAccountService.init();
  }

  static bool hasStreaming(String name) =>
      StreamingAccountService.isConnected(name);
}
