import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/streaming_account_model.dart';
import '../constants/streaming_constants.dart';

class StreamingAccountService {
  static const _accountsKey = 'streaming_accounts';
  static const _storage = FlutterSecureStorage();

  static late SharedPreferences _prefs;
  static final Map<String, StreamingAccountModel> _accounts = {};

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadAccounts();
    for (final name in StreamingConstants.allProviderNames) {
      _accounts.putIfAbsent(
        name,
        () => StreamingAccountModel(providerName: name, isConnected: false),
      );
    }
  }

  static void _loadAccounts() {
    final data = _prefs.getString(_accountsKey);
    if (data == null) return;
    final map = jsonDecode(data) as Map<String, dynamic>;
    for (final entry in map.entries) {
      _accounts[entry.key] = StreamingAccountModel.fromJson(
        entry.value as Map<String, dynamic>,
      );
    }
  }

  static Future<void> _save() async {
    final map = _accounts.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs.setString(_accountsKey, jsonEncode(map));
  }

  static List<StreamingAccountModel> getAllAccounts() {
    return StreamingConstants.allProviderNames
        .map((n) =>
            _accounts[n] ??
            StreamingAccountModel(providerName: n, isConnected: false))
        .toList();
  }

  static List<StreamingAccountModel> getConnectedAccounts() {
    return getAllAccounts().where((a) => a.isConnected).toList();
  }

  static List<StreamingAccountModel> getInactiveAccounts() {
    return getConnectedAccounts()
        .where((a) => a.shouldShowInactivityAlert)
        .toList();
  }

  static StreamingAccountModel getAccount(String providerName) {
    return _accounts[providerName] ??
        StreamingAccountModel(providerName: providerName, isConnected: false);
  }

  static bool isConnected(String providerName) {
    return getAccount(providerName).isConnected;
  }

  static Future<void> connectAccount(
      String providerName, String email, String password) async {
    final existing = _accounts[providerName] ??
        StreamingAccountModel(providerName: providerName, isConnected: false);
    _accounts[providerName] = existing.copyWith(
      isConnected: true,
      userEmail: email,
    );
    await _storage.write(key: 'pwd_$providerName', value: password);
    await _save();
  }

  static Future<String?> getPassword(String providerName) async {
    return _storage.read(key: 'pwd_$providerName');
  }

  static Future<void> disconnectAccount(String providerName) async {
    _accounts[providerName] =
        StreamingAccountModel(providerName: providerName, isConnected: false);
    await _storage.delete(key: 'pwd_$providerName');
    await _save();
  }

  static Future<void> recordUsage(String providerName) async {
    final account = _accounts[providerName];
    if (account == null || !account.isConnected) return;
    _accounts[providerName] = account.copyWith(lastUsed: DateTime.now());
    await _save();
  }

  static Future<void> snoozeAlert(String providerName) async {
    final account = _accounts[providerName];
    if (account == null) return;
    _accounts[providerName] = account.copyWith(
      snoozedUntil: DateTime.now().add(const Duration(days: 7)),
    );
    await _save();
  }
}
