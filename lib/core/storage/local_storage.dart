import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageProvider = Provider<LocalStorage>((ref) => throw UnimplementedError());

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // Initialize SharedPreferences asynchronously
  static Future<LocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  // Token management
  static const String _kAccessToken = 'access_token';

  Future<void> saveToken(String token) async {
    await _prefs.setString(_kAccessToken, token);
  }

  String? getToken() {
    return _prefs.getString(_kAccessToken);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_kAccessToken);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
