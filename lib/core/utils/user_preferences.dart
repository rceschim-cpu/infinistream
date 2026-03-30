import '../services/auth_service.dart';
import '../services/streaming_account_service.dart';

class UserPreferences {
  static Future<void> load() async {
    await AuthService.init();
    await StreamingAccountService.init();
  }

  // Mantido para compatibilidade com código existente
  static bool hasStreaming(String name) =>
      StreamingAccountService.isConnected(name);
}
