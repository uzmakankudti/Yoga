import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey = 'role';
  static const _userIdKey = 'user_id';

  Future<String?> getAccessToken() async =>
      (await SharedPreferences.getInstance()).getString(_accessKey);

  Future<String?> getRefreshToken() async =>
      (await SharedPreferences.getInstance()).getString(_refreshKey);

  Future<String?> getRole() async =>
      (await SharedPreferences.getInstance()).getString(_roleKey);

  Future<String?> getUserId() async =>
      (await SharedPreferences.getInstance()).getString(_userIdKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, accessToken);
    await prefs.setString(_refreshKey, refreshToken);
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    String? role,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, accessToken);
    await prefs.setString(_refreshKey, refreshToken);
    if (role != null) await prefs.setString(_roleKey, role);
    if (userId != null) await prefs.setString(_userIdKey, userId);
  }

  Future<void> saveRole(String role) async =>
      (await SharedPreferences.getInstance()).setString(_roleKey, role);

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userIdKey);
  }
}
