import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageProvider = Provider<LocalStorage>(
  (ref) => throw UnimplementedError(),
);

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
  static const String _kCachedUser = 'cached_user';

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

  // ─────────────────────────────────────────────────────────────
  // Cached User Profile — hiện ngay khi mở app, không đợi network
  // ─────────────────────────────────────────────────────────────

  /// Lưu user profile JSON để hiện ngay lần sau
  Future<void> saveUserProfile(Map<String, dynamic> userJson) async {
    await _prefs.setString(_kCachedUser, jsonEncode(userJson));
  }

  /// Đọc cached user — sync, < 1ms
  Map<String, dynamic>? getCachedUserJson() {
    final raw = _prefs.getString(_kCachedUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCachedUser() async {
    await _prefs.remove(_kCachedUser);
  }

  // Clear all
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
