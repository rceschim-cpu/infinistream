import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const _userKey = 'user_data';
  static const _loggedInKey = 'is_logged_in';

  static UserModel? _currentUser;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final userData = _prefs!.getString(_userKey);
    if (userData != null && _prefs!.getBool(_loggedInKey) == true) {
      try {
        _currentUser = UserModel.fromJson(
          jsonDecode(userData) as Map<String, dynamic>,
        );
      } catch (_) {}
    }
  }

  static UserModel? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  static String _hash(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Retorna null em caso de sucesso, ou uma mensagem de erro.
  static Future<String?> register(
      String name, String email, String password) async {
    final existing = _prefs!.getString(_userKey);
    if (existing != null) {
      final user = UserModel.fromJson(
        jsonDecode(existing) as Map<String, dynamic>,
      );
      if (user.email.toLowerCase() == email.toLowerCase()) {
        return 'Este e-mail já está cadastrado.';
      }
    }

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      passwordHash: _hash(password),
      createdAt: DateTime.now(),
    );

    await _prefs!.setString(_userKey, jsonEncode(user.toJson()));
    await _prefs!.setBool(_loggedInKey, true);
    _currentUser = user;
    return null;
  }

  /// Retorna null em caso de sucesso, ou uma mensagem de erro.
  static Future<String?> login(String email, String password) async {
    final userData = _prefs!.getString(_userKey);
    if (userData == null) return 'Nenhuma conta encontrada.';

    final user = UserModel.fromJson(
      jsonDecode(userData) as Map<String, dynamic>,
    );
    if (user.email.toLowerCase() != email.toLowerCase()) {
      return 'E-mail ou senha incorretos.';
    }
    if (user.passwordHash != _hash(password)) {
      return 'E-mail ou senha incorretos.';
    }

    await _prefs!.setBool(_loggedInKey, true);
    _currentUser = user;
    return null;
  }

  static Future<void> logout() async {
    await _prefs!.setBool(_loggedInKey, false);
    _currentUser = null;
  }
}
