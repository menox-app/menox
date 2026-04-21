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

  // Token keys
  static const String _kAccessToken = 'access_token';
  static const String _kRefreshToken = 'refresh_token';

  // Save both tokens at once
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _prefs.setString(_kAccessToken, accessToken),
      _prefs.setString(_kRefreshToken, refreshToken),
    ]);
  }

  // Access Token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_kAccessToken, token);
  }

  String? getToken() {
    return _prefs.getString(_kAccessToken);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_kAccessToken);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(_kRefreshToken, token);
  }

  String? getRefreshToken() {
    return _prefs.getString(_kRefreshToken);
  }

  Future<void> removeRefreshToken() async {
    await _prefs.remove(_kRefreshToken);
  }

  // Clear all
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

